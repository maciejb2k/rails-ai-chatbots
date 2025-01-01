class CreateChatbotCreations < ActiveRecord::Migration[7.2]
  def change
    create_table :chatbot_creations, id: :uuid do |t|
      t.integer :status, default: 0, null: false
      t.text :scraped_content
      t.string :chatflow_id
      t.string :document_store_id
      t.jsonb :context, default: {}, null: false
      t.jsonb :process_errors, default: [], null: false
      t.references :company, type: :uuid, null: false, foreign_key: true
      t.timestamps
    end
  end
end
