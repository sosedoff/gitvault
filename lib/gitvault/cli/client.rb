module Gitvault
  module CLI
    class Client
      include Request
      include Repositories
      include PublicKeys
    
      attr_reader :api_base
    
      def initialize(host)
        @api_base = host
      end
      
      def version
        get('/version')
      end
    end
  end
end