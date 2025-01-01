class CreateTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :tokens, id: :uuid do |t|
      t.string :key, null: false, index: { unique: true }
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end
