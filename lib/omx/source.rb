require "patron"
require 'active_support/all'
require "omx/connection"
require "omx/parser"

module Omx
  class Source

    INSTRUMENT = {
      "indu-c" => "SSE3966",
      "kinnevik-b" => "SSE999",
      "ratos-b" => "SSE1045",
      "duni" => "SSE49775",
      "hm-b" => "SSE992"
    }

    def initialize
      @http = Connection.new
    end

    def closing_price(ticker, date=Time.now.to_date.to_s)
      to = date.to_s.match(/^\d{4}$/) ? end_of_year(date) : date
      from = (Date.parse(to) - 7.days).to_s(:db)
      body = http.post(INSTRUMENT[ticker], from, to)

      Parser.new(body).closing_price
    end

    private

    attr_reader :http

    def end_of_year(year)
      (Date.new(year.to_i + 1, 1, 1) - 1.day).to_s(:db)
    end

  end
end

