module Chatbots
  class Dispatcher < ApplicationService
    Result = Struct.new(:status, :creation, :error, keyword_init: true)

    def initialize(url:, token:)
      @url = DomainParser.call(url)
      @token = Rails.env.production? ? Token.find_by(key: token) : true
    end

    def call
      return Result.new(status: :url_invalid, error: "URL is invalid") if @url.nil?
      return Result.new(status: :token_invalid, error: "Token is invalid") if @token.nil?

      company = find_or_create_company
      handle_chatbot_state(company)
    end

    private

    def find_or_create_company
      company = Company.find_or_initialize_by(url: @url)
      company.save! unless company.persisted?
      company
    end

    def handle_chatbot_state(company)
      if latest_creation = company.latest_chatbot
        Result.new(status: :ready, creation: latest_creation)
      elsif active_creation = company.active_creation
        Result.new(status: :in_progress, creation: active_creation)
      elsif failed_creation = company.failed_creation
        Result.new(status: :failed, creation: failed_creation)
      else
        start_new_chatbot_creation(company)
      end
    end

    def start_new_chatbot_creation(company)
      return Result.new(status: :in_progress, creation: company.active_creation) unless company.can_start_new_creation?

      chatbot_creation = company.chatbot_creations.create!
      ChatbotCreationPipelineJob.perform_later(company_id: company.id, chatbot_creation_id: chatbot_creation.id)

      Result.new(status: :in_progress, creation: chatbot_creation)
    end
  end
end
