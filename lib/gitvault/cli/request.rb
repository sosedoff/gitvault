require 'faraday'
require 'faraday_middleware'
require 'multi_json'

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