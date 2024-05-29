class Message < ApplicationRecord
  belongs_to :chat
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def as_indexed_json(options = {})
    as_json(only: [:id, :body, :chat_id, :message_number])
  end

  def self.search(query, chat_id)
    __elasticsearch__.search(
      {
        query: {
          bool: {
            must: {
              match: {
                body: {
                  query: query,
                }
              }
            },
            filter: {
              term: {
                chat_id: chat_id
              }
            }
          }
        }
      }
    )
  end

end

# Recreate the index with the new mapping
Message.__elasticsearch__.create_index!(force: true)
Message.import # for auto sync model with elastic search
