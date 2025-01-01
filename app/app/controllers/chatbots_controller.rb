class ChatbotsController < ApplicationController
  before_action :set_token, only: :index

  def index
    return if params[:url].blank?

    result = Chatbots::Dispatcher.call(url: params[:url], token: @token)
    render_response(result)
  end

  def scraped_data
    chatbot_creation = Company.find_by!(url: params[:url]).chatbot_creations.order(created_at: :desc).first

    if chatbot_creation.present?
      render json: { scraped_content: chatbot_creation.scraped_content }
    else
      render json: { message: "company not found", scraped_content: nil }
    end
  end

  private

  def render_response(result)
    case result.status
    when :ready
      render "chatbot", locals: { chatbot_creation: result.creation }
    when :in_progress
      render "creation_progress", locals: { chatbot_creation: result.creation }
    when :failed
      render "creation_progress", locals: { chatbot_creation: result.creation }
    when :token_invalid
      render json: { message: "Token is invalid" }, status: :unauthorized
    when :url_invalid
      render json: { message: "URL is invalid" }, status: :unprocessable_entity
    end
  end

  def set_token
    @token = Token.find_by(key: params[:token])
  end
end
