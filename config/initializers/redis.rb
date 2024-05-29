require 'redis'
Redis::Module = Redis.new(host: ENV['REDIS_HOST'], port: 6379)
