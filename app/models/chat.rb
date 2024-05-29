class Chat < ApplicationRecord
  belongs_to :application
  has_many :messages
  validates :chat_number, presence: true, uniqueness: { scope: :application_id }
end
