require "patron"
require 'active_support/all'
require "omx/connection"
require "omx/parser"
require "config"

module Omx
  class Source
    attr_reader :persistence

    def initialize(options={})
      @persistence = Blossom::Config.persistence || NoPersistence.new
    end

    def closing_price(ticker, date=Time.now.to_date.to_s)
      persistence.store(ticker, date) do
        to = date.to_s.match(/^\d{4}$/) ? end_of_year(date) : date
        from = (Date.parse(to) - 7.days).to_s(:db)
        body = http.post(Blossom::Config.omx_symbols[ticker], from, to)

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

