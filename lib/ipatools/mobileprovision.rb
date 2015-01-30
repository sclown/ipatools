require 'openssl'
require 'rexml/document'

module Ipatools

  class Mobileprovision

    def initialize (path)
      p path
      if self.class.UUID? path
        @filepath = self.class.libraryPath path
      else
        @filepath = path
      end
      @plist = REXML::Document.new(self.class.plist @filepath)
    end

    def self.UUID?(path)
      path =~ /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/
    end

    def self.libraryPath (uuid)
      "#{Dir.home}/Library/MobileDevice/Provisioning\ Profiles/#{uuid}.mobileprovision"
    end

    def self.plist (filepath)
      p7 = OpenSSL::PKCS7.new(File.read(filepath))
      store = OpenSSL::X509::Store.new
      p7.verify(nil, store, nil, OpenSSL::PKCS7::NOVERIFY)
      p7.data
    end

    def pem
      keys = @plist.elements['/plist/dict/key[text() = "DeveloperCertificates"]'].next_element
      key = keys.get_elements('//array/data')[0].text
      "-----BEGIN CERTIFICATE-----\n" + key.scan(/.{1,64}/).join("\n") + "\n-----END CERTIFICATE-----"
    end

    def identity
      self.class.findIdentity(self.sha1)
    end

    def sha1
      self.class.findSHA1(self.pem)
    end

    def self.findSHA1 (pem)
      all_certs = `security find-certificate -a -Z -p`
      p all_certs.length
      all_certs.scan(/SHA-1 hash: (\h*)\n(-----BEGIN CERTIFICATE-----\n[^-]*\n-----END CERTIFICATE-----)/m).each { |cert|
        if cert[1] == pem
          p cert[0]
          return cert[0]
        end
      }

    end

    def self.findIdentity (sha1)
      ident_result = `security find-certificate -a -Z | grep #{sha1} -A 5`.scan(/"alis"<blob>="([^"]+)"/)
      ident_result[0][0]
    end

    def UUID
      @plist.elements['/plist/dict/key[text() = "UUID"]'].next_element.text
    end

    def install
      cmd = %Q(cp "#{@filepath}" "#{self.class.libraryPath self.UUID}")
      puts cmd
      `#{cmd}`
    end

    def embed path
      `cp -f "#{@filepath}" "#{path}/embedded.mobileprovision"`
    end

  end

end
