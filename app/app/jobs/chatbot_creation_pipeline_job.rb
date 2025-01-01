class ChatbotCreationPipelineJob < ApplicationJob
  def perform(company_id:, chatbot_creation_id:)
    company = Company.find(company_id)
    chatbot_creation = ChatbotCreation.find(chatbot_creation_id)

    return if chatbot_creation.is_manual? && chatbot_creation.scraped_content.empty?

    sleep 1

    Chatbots::Pipeline.new(company:, chatbot_creation:).run
  end
end
