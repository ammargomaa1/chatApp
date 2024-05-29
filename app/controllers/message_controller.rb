class MessageController < ActionController::API

  require 'redis'
  REDIS = Redis.new(host: ENV['REDIS_HOST'], port: 6379)

  def create
    application_token = params[:application_token]
    chat_number = params[:chat_number]
    body = params[:body]


    application = Application.find_by(token: application_token)
    if application.nil?
      render json: { error: 'Application not found' }, status: :not_found and return
    end

    chat = Chat.find_by(application_id: application.id, chat_number: chat_number)

    if chat.nil?
      render json: { error: 'Chat not found' }, status: :not_found and return
    end

    # Acquire Redis lock
    lock_key = "lock:#{application_token}#{chat_number}"
    if REDIS.set(lock_key, 'locked', nx: true, ex: 5)
      begin
        # Increment chat number
        message_number_key = "message_number:#{application_token}#{chat_number}"
        message_number = REDIS.incr(message_number_key)

        # Create chat record
        ProcessMessageJob.perform_now(application_token, chat_number, message_number, body)
        render json: {message_number: message_number}, status: :created
      ensure
        # Release the lock
        REDIS.del(lock_key)
      end
    else
      render json: { error: 'Unable to acquire lock, please try again' }, status: :too_many_requests
    end
  end

  def search
    query = params[:query]
    application_token = params[:application_token]
    chat_number = params[:chat_number]
    application = Application.find_by(token: application_token)
    if application.nil?
      render json: { error: 'Application not found' }, status: :not_found and return
    end

    chat = Chat.find_by(application_id: application.id, chat_number: chat_number)

    if chat.nil?
      render json: { error: 'Chat not found' }, status: :not_found and return
    end

    if query.present?
      @messages = Message.search(query, chat.id)
      messages = @messages.map do |mess|
        { body: mess.body, message_number: mess.message_number }
      end
      render json: messages
    else
      render json: { error: 'Query parameter is missing' }, status: :bad_request
    end
  end
end
