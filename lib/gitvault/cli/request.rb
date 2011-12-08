require 'faraday'
require 'faraday_middleware'
require 'multi_json'

module Gitvault
  module ErrorHelper
    
    def raise_error(code, message='')
      case code
        when 400 then raise Gitvault::CLI::BadRequest.new message
        when 401 then raise Gitvault::CLI::Unauthorized.new message
        when 403 then raise Gitvault::CLI::Forbidden.new message
        when 404 then raise Gitvault::CLI::NotFound.new message
        when 406 then raise Gitvault::CLI::BadRequest.new message
        when 500 then raise Gitvault::CLI::InternalError.new message
        when 502 then raise Gitvault::CLI::BadGateway.new message
      end
    end
    
    def on_complete(response)
      raise_error(response[:status].to_i)
    end
  end
end

module Faraday
  class Response::RaiseGitvaultError < Response::Middleware
    include Gitvault::ErrorHelper
  end
end

module Gitvault
  module CLI
    module Request
      protected

      def get(path, options={})
        request(:get, path, options)
      end

      def post(path, options={})
        request(:post, path, options)
      end

      def put(path, options={})
        request(:put, path, options)
      end

      def delete(path, options={})
        request(:delete, path, options)
      end

      private

      def connection(url)
        connection = Faraday.new(url) do |c|
          c.use(Faraday::Request::UrlEncoded)
          c.use(Faraday::Response::ParseJson)
          c.use(Faraday::Response::RaiseGitvaultError)
          c.adapter(Faraday.default_adapter)
        end
      end

      def request(method, path, params={}, raw=false)
        response = connection(api_base).send(method) do |request|
          case method
            when :delete, :get
              request.url(path, params)
            when :post, :put
              request.path = path
              request.body = params unless params.empty?
          end
        end
        raw ? response : response.body
      end
    end
  end
end