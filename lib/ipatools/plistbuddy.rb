module Ipatools

  class PlistBuddy
    PLIST_BUDDY = '/usr/libexec/PlistBuddy'

    def initialize(file, &block)
      unless File.exist?(File.expand_path(file))
        raise(ArgumentError, "plist '#{file}' does not exist - could not read")
      end
      @plist=file
      instance_eval(&block)
    end

    def set(key, type, value)
      if self.key_exist?(key)
        cmd({:cmd => :set, :key => key, :value => value})
      else
        cmd({:cmd => :add, :key => key, :type => type, :value => value})
      end
      puts self.read key
      self
    end

    def delete(key)
      cmd({:cmd => :delete, :key => key})
      self
    end

    def key_exist?(key)
      self.read(key) != nil

    end

    def read(key)
      res = cmd({:cmd => :print, :key => key})
    end

    private

    def cmd(command)
      plist_cmd = "#{PLIST_BUDDY} -c #{self.class.build(command)} \"#{@plist}\""
      puts plist_cmd
      `#{plist_cmd}`
    end

    def self.build(args_hash)
      case args_hash[:cmd]
        when :add
          value_type = args_hash[:type]
          unless value_type
            raise(ArgumentError, ':value_type is a required key for :add command')
          end
          allowed_value_types = ['string', 'bool', 'real', 'integer']
          unless allowed_value_types.include?(value_type)
            raise(ArgumentError, "expected '#{value_type}' to be one of '#{allowed_value_types}'")
          end
          value = args_hash[:value]
          unless value
            raise(ArgumentError, ':value is a required key for :add command')
          end
          key = args_hash[:key]
          unless key
            raise(ArgumentError, ':key is a required key for :add command')
          end
          return "\"Add :#{key} #{value_type} #{value}\""
        when :set
          value = args_hash[:value]
          unless value
            raise(ArgumentError, ':value is a required key for :set command')
          end
          key = args_hash[:key]
          unless key
            raise(ArgumentError, ':key is a required key for :set command')
          end
          return "\"Set :#{key} #{value}\""
        when :print
          key = args_hash[:key]
          unless key
            raise(ArgumentError, ':key is a required key for :print command')
          end
          return "\"Print :#{key}\""
        when :delete
          key = args_hash[:key]
          unless key
            raise(ArgumentError, ':key is a required key for :delete command')
          end
          return "\"Delete :#{key}\""
        else
          cmds = [:add, :set, :print, :delete]
          raise(ArgumentError, "expected '#{args_hash[:cmd]}' to be one of '#{cmds}'")
      end
    end
  end
end
