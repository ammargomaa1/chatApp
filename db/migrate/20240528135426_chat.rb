class Chat < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.integer :chat_number
      t.references :application, foreign_key: true
      t.integer :messages_count, default: 0
      t.timestamps
  end
  add_index :chats, :chat_number, unique: true
end
