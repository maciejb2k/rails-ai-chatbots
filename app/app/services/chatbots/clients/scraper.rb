module Chatbots
  module Clients
    class Scraper < BaseClient
      def initialize
        super(base_url: ENV["SCRAPER_URL"])
      end

      def get_info
        response = connection.get "/"
        response.body
      end

      def scrape_website(url:)
        response = connection.get "/scrape", url: url
        response.body
      end

      def scrape_mocked_website(url:)
        response = connection.get "/scrape-mocked", url: url
        response.body
      end
    end
  end
end
