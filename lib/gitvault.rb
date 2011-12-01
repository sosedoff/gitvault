require 'gitvault/version'
require 'gitvault/configuration'

module Gitvault
  extend self
  
  def configure(input)
    @configuration = Gitvault::Configuration.new(input)
  end
  
  def configuration
    default_options = {
      'repositories'    => '/tmp/gitvault/repositories',
      'authorized_keys' => '/tmp/gitvault/authorized_keys'
    }
    @configuration ||= Gitvault::Configuration.new(default_options)
  end
end
