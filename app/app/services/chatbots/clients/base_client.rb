module Chatbots
  module Clients
    class BaseClient
      attr_reader :connection

      def initialize(base_url:, headers: {})
        @connection = Faraday.new(url: base_url) do |faraday|
          faraday.request :json
          faraday.response :json
          faraday.adapter Faraday.default_adapter
          faraday.response :raise_error # raise exceptions on 40x, 50x responses
          faraday.headers = default_headers.merge(headers)
        end
      end

      private

      def default_headers
        {
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      end
    end
  end
end
