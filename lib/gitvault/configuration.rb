require 'yaml'

module Gitvault
  class Configuration
    attr_reader :keys
    
    def initialize(input)
      unless [Hash, String].include?(input.class)
        raise ArgumentError, "File path or hash required!"
      end
      
      @keys = {}
      
      if input.kind_of?(String)
        @keys.merge!(YAML.load_file(input))
      elsif input.kind_of?(Hash)
        @keys.merge!(input)
      end
      
      unless @keys.key?('repositories')
        raise ConfigError, "'repositories' key is not defined!"
      end
      
      unless @keys.key?('authorized_keys')
        raise ConfigError, "'authorized_keys' key is not defined!"
      end
    end
    
    def method_missing(key)
      @keys[key]
    end
    
    def to_s
      @keys.to_s
    end
  end
end
