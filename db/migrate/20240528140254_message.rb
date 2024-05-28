class Message < ActiveRecord::Migration[7.1]
  def change
    create_table :messages
    t.text :body
    t.references :chat, foreign_key: true
    t.integer :number
    t.timestamps
  end
end
