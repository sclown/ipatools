require 'pathname'
require 'tmpdir'

require "ipatools/mobileprovision"

module Ipatools

  class Ipa
    PAYLOAD = 'Payload'
    attr_reader :ipa_path
    attr_reader :content
    attr_reader :app

    def initialize(path)
      input = Pathname(path)
      if input.extname == '.ipa'
        @ipa_path = input
      elsif Dir.exist?(input)
        @content = input
        Dir.chdir(input) {
          @app = Pathname(input) + Dir["*.app"][0]
        }
      end
    end

    def pack(ipa_path)
      Dir.chdir(@content.dirname) {
        FileUtils.remove(ipa_path) if File.exist?(ipa_path)
        cmd = %Q(zip -ry "#{ipa_path}" #{PAYLOAD})
        puts cmd
        `#{cmd}`
      }
    end

    def sign(profile, entitlements)
      profileObject = Mobileprovision.new(profile)
      profileObject.embed(@app)
      identity = profileObject.identity
      entitlements ||= self.findEntitlements

      sign_path = @app + '_CodeSignature'
      FileUtils.rm_r(sign_path) if Dir.exist?(sign_path)
      p %Q(/usr/bin/codesign -f --entitlements "#{entitlements}" -s "#{identity}" "#{@app}")
      `/usr/bin/codesign -f --entitlements "#{entitlements}" -s "#{identity}" "#{@app}"`
    end

    def prepare
      Dir.mktmpdir { |dir|
        payload_path = Pathname(dir) + PAYLOAD
        Dir.mkdir(payload_path)
        FileUtils.cp_r("#{@app}", payload_path)
        yield Ipa.new(payload_path) if block_given?
      }
    end

    def unpack
      Dir.mktmpdir { |dir|
        `unzip #{@ipa_path} -d #{dir}`
        yield Ipa.new("#{dir}/Payload") if block_given?
      }
    end

    def findEntitlements
      entitlements = nil;
      Dir.chdir(@app) {
        entitlements = @app + Dir["*.xcent"][0]
      }
      entitlements
    end
  end
end

