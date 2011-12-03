module Gitvault::CLI
  class Account
    attr_accessor :name, :url
    
    def initialize(name, url)
      @name = name
      @url  = url
    end
    
    def valid?
      begin
        Gitvault::CLI::Client.new(url).version
        true
      rescue Exception
        false
      end
    end
    
    def to_s
      @url
    end
  end
end
