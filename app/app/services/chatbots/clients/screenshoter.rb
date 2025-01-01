module Chatbots
  module Clients
    class Screenshoter < BaseClient
      def initialize
        super(base_url: ENV["SCREENSHOTER_URL"])
      end

      def take_screenshot(url:, chatbot_creation_id:)
        response = connection.get "/screenshot", url: url, chatbot_creation_id: chatbot_creation_id
        response.body
      end
    end
  end
end
