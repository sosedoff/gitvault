require 'gitvault/ssh/git'
require 'gitvault/ssh/session'

module Gitvault
  module SSH
    class << self
      def new(args, env)
        Gitvault::SSH::Session.new(args, env)
      end
    end
  end
end
