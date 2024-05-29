class Application < ApplicationRecord
  has_many :chats
  validates :name, presence: true
  validates :token, presence: true, uniqueness: true
end
