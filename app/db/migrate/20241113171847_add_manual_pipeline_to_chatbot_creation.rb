class AddManualPipelineToChatbotCreation < ActiveRecord::Migration[7.2]
  def change
    add_column :chatbot_creations, :is_manual, :boolean, default: false
  end
end
