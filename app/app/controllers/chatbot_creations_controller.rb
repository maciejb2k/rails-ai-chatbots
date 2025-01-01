class ChatbotCreationsController < ApplicationController
  before_action :set_model, only: [ :update ]

  skip_before_action :verify_authenticity_token

  def update
    if @model.update(model_params)
      render json: { status: "success", message: "Screenshot updated successfully." }
    else
      render json: { status: "error", message: @model.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_model
    @model = ChatbotCreation.find(params[:id])
  end

  def model_params
    params.require(:chatbot_creation).permit(:screenshot)
  end
end
