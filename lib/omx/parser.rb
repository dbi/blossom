# encoding: UTF-8

module Omx
  class Parser
    attr_reader :body

    def initialize(body)
      @body = body
    end

    def closing_price
      raise "unknown html" unless body.include? '<tr id="historicalTable-">'

      table_headers = []
      data = []
      body.each_line do |line|
        if line.match /title\="(.+)"/
          table_headers << $1.force_encoding("UTF-8")
        elsif line.match /<td>(.*)<\/td>/
          data << $1
        end
      end
      index_of_closing_price = table_headers.index("Stängningskurs")
      closing_price_data = data[-(table_headers.size - index_of_closing_price)].gsub(',', '.')

      raise "closing price is not a number" unless closing_price_data.match /^\d+\.\d+$/
      closing_price_data.to_f
    end

  end
end
