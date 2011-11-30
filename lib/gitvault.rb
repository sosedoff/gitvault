require 'gitvault/version'
require 'gitvault/configuration'

module Gitvault
  @@configuration = nil
  
  class << self
    def configure(input)
      @@configuration = Gitvault::Configuration.new(input)
    end
    
    def config
      @@configuration
    end
  end
end
