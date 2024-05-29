class ProcessMessageJob < ApplicationJob
  queue_as :default

  def perform(application_token, chat_id, message_number, body)
    application = Application.find_by(token: application_token)
    chat = Chat.find_by(application_id: application.id, id: chat_id)

    return if chat.nil? || application.nil?

    message = chat.messages.create(message_number: message_number, body: body)

    if message.persisted?
      # Index the message in Elasticsearch
      message.__elasticsearch__.index_document
    end
  end
end
