module Chatbots
  class Pipeline
    class EmptyScrapedDataError < StandardError; end
    class DocumentStoreAlreadyExistsError < StandardError; end
    class MissingOpenAICredentialsError < StandardError; end
    class MissingPostgresCredentialsError < StandardError; end
    class MissingChatflowTemplateError < StandardError; end
    class TokenNotFoundError < StandardError; end
    class NotAllowedDomainError < StandardError; end

    OPENAI_CREDENTIALS_NAME = "OpenAI".freeze
    POSTGRES_CREDENTIALS_NAME = "Postgres".freeze
    TEMPLATE_NAME = "chatbot_template".freeze

    attr_reader :company, :chatbot_creation, :context

    def initialize(company:, chatbot_creation:)
      @company = company
      @chatbot_creation = chatbot_creation
      @context = {}

      @scraper_client = Chatbots::Clients::Scraper.new
      @flowise_client = Chatbots::Clients::Flowise.new
      @screenshoter_client = Chatbots::Clients::Screenshoter.new
    end

    def run
      raise NotAllowedDomainError if Chatbots::DomainWhitelist.allowed?(@company.url)

      scraping_step unless @chatbot_creation.is_manual?
      document_store_creation_step
      process_all_loaders_step
      data_loading_step
      chatflow_creation_step
      screenshot_step
    rescue => e
      @chatbot_creation.process_errors ||= []
      @chatbot_creation.process_errors << { error_type: e.class.to_s, message: e.message, occurred_at: Time.current, backtrace: e.backtrace }
      @chatbot_creation.update!(status: :failed, process_errors: @chatbot_creation.process_errors)

      raise e
    end

    private

    def scraping_step
      @chatbot_creation.update!(status: :scraping)

      # Scrape company website
      response = @scraper_client.scrape_website(url: @company.url)
      scraped_content = response["data"]

      # Check if scraped content is empty
      raise EmptyScrapedDataError if scraped_content.empty?

      @chatbot_creation.update!(scraped_content:)
    end

    def document_store_creation_step
      @chatbot_creation.update!(status: :creating_document_store)

      # Get all document stores
      response = @flowise_client.get_document_stores

      # Check if document store already exists (based on company URL)
      document_store_id = nil
      response.each do |document_store|
        if document_store["name"] == @company.url
          document_store_id = document_store["id"]
          break
        end
      end

      token = Token.first
      raise TokenNotFoundError if token.nil?

      # Create document store if it doesn't exist
      unless document_store_id
        response = @flowise_client.create_document_store(
          url: @company.url,
          description: "External Integration, #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}",
          token: token.key
        )

        document_store_id = response["id"]

        @flowise_client.create_api_loader(document_store_id:, url: @company.url, token: token)
        @flowise_client.wait_for_loaders_to_sync(document_store_id:)

        # Flag to not process all loaders again if document store is newly created
        context.merge!(are_loaders_synced: true)
      end

      context.merge!(document_store_id:)
      @chatbot_creation.update!(document_store_id:)
    end

    def process_all_loaders_step
      # Flag from previous step to not process all loaders again if document store is newly created
      return if context[:are_loaders_synced]

      @chatbot_creation.update!(status: :processing_loaders)

      @flowise_client.process_all_loaders(document_store_id: context[:document_store_id])
      @flowise_client.wait_for_loaders_to_sync(document_store_id: context[:document_store_id])
    end

    def data_loading_step
      @chatbot_creation.update!(status: :loading_data)

      # Get Credentials
      credentials_response = @flowise_client.get_credentials

      # Find OpenAI and Postgres credentials
      openai_credentials_id = nil
      postgres_credentials_id = nil
      credentials_response.each do |credential|
        openai_credentials_id = credential["id"] if credential["name"] == OPENAI_CREDENTIALS_NAME
        postgres_credentials_id = credential["id"] if credential["name"] == POSTGRES_CREDENTIALS_NAME
      end

      # Check if OpenAI or Postgres credentials are missing
      raise MissingOpenAICredentialsError if openai_credentials_id.nil?
      raise MissingPostgresCredentialsError if postgres_credentials_id.nil?

      # Save configuration for document store
      @flowise_client.insert_configuration(
        document_store_id: context[:document_store_id],
        url: @company.url,
        openai_credentials_id:,
        postgres_credentials_id:,
      )

      # Update configuration for document store
      @flowise_client.upsert_configuration(
        document_store_id: context[:document_store_id],
        url: @company.url,
        openai_credentials_id:,
        postgres_credentials_id:,
      )

      context.merge!(openai_credentials_id:, postgres_credentials_id:)
    end

    def chatflow_creation_step
      @chatbot_creation.update!(status: :creating_chatflow)

      # Get all templates
      response = @flowise_client.get_templates

      # Find chatflow template
      chatflow_template = nil
      response.each do |template|
        if template["name"] == TEMPLATE_NAME
          chatflow_template = template
          break
        end
      end

      # Check if chatflow template is missing
      raise MissingChatflowTemplateError if chatflow_template.nil?

      # Save template chatflow data
      parsed_flowdata = JSON.parse(chatflow_template["flowData"], symbolize_names: true)
      parsed_flowdata[:nodes][0][:data][:credential] = context[:openai_credentials_id]
      parsed_flowdata[:nodes][1][:data][:inputs][:selectedStore] = context[:document_store_id]

      # Create chatflow
      response = @flowise_client.create_chatflow(
        openai_credentials_id: context[:openai_credentials_id],
        document_store_id: context[:document_store_id],
        flowdata: JSON.generate(parsed_flowdata),
        url: @company.url
      )

      # Save chatflow ID
      chatflow_id = response["id"]

      # Update chatbot creation
      @chatbot_creation.update!(chatflow_id: chatflow_id)
    end

    def screenshot_step
      @chatbot_creation.update!(status: :preparing_view)

      @screenshoter_client.take_screenshot(url: "http://#{@company.url}", chatbot_creation_id: @chatbot_creation.id)

      @chatbot_creation.update!(status: :ready)
    end
  end
end
