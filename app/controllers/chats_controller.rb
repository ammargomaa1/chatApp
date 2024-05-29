class ChatsController < ActionController::API
  require 'redis'
  REDIS = Redis.new(host: ENV['REDIS_HOST'], port: 6379)

  def create
    application_token = params[:application_token]
    application = Application.find_by(token: application_token)

    if application.nil?
      render json: { error: 'Application not found' }, status: :not_found and return
    end

    # Acquire Redis lock
    lock_key = "lock:#{application_token}"
    if REDIS.set(lock_key, 'locked', nx: true, ex: 5)
      begin
        # Increment chat number
        chat_number_key = "chat_number:#{application_token}"
        chat_number = REDIS.incr(chat_number_key)

        # Create chat record
        chat = application.chats.build(chat_number: chat_number)
        if chat.save
          render json: {chat_number: chat.chat_number}, status: :created
        else
          render json: chat.errors, status: :unprocessable_entity
        end
      ensure
        # Release the lock
        REDIS.del(lock_key)
      end
    else
      render json: { error: 'Unable to acquire lock, please try again' }, status: :too_many_requests
    end
  end

end
