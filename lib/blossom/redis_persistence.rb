require "redis"

module Blossom
  class RedisPersistence

    def store(ticker, date)
      key = ticker_key ticker, date

      unless price = redis.get(key)
        price = yield ticker, date
        redis.set key, price
        puts "store: #{key} = #{price}"
      end

      price.to_f
    end

    private

    def ticker_key(ticker, date)
      "blossom-#{ticker}-#{date}"
    end

    def redis
      @redis ||= Redis.new
    end

  end
end

