class Message < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :chat, foreign_key: true
      t.integer :message_number
      t.timestamps
    end # Added missing closing 'end' here
  end
end