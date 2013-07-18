require "patron"
require "active_support/all"
require "omx/connection"
require "omx/parser"
require "blossom/config"

module Omx
  class Source
    attr_reader :persistence

    TICKER_CONVERSION_TABLE = {
      "indu-c" => "SSE3966",
      "kinnevik-b" => "SSE999",
      "ratos-b" => "SSE1045",
      "duni" => "SSE49775",
      "hm-b" => "SSE992"
    }

    # Initializes a snapshot of a stock portfolio.
    #
    # options - :persistence - A object that is reponsible for persisting dates and stock
    #                          prices. The object should repond to #store(ticker, date)
    #                          yield the method parameters and repond with the result of
    #                          the yield.
    #
    def initialize(options={})
      @persistence = options[:persistence] || NoPersistence.new
    end

    def closing_price(ticker, date=Time.now.to_date.to_s)
      persistence.store(ticker, date) do
        to = date.to_s.match(/^\d{4}$/) ? end_of_year(date) : date
        from = (Date.parse(to) - 7.days).to_s(:db)
        body = http.post(TICKER_CONVERSION_TABLE[ticker], from, to)

        Parser.new(body).closing_price
      end
    end

    private

    def http
      @http ||= Connection.new
    end

    def end_of_year(year)
      (Date.new(year.to_i + 1, 1, 1) - 1.day).to_s(:db)
    end

    class NoPersistence
      def store(key, value)
        yield
      end
    end

  end
end

