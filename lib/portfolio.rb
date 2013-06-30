require 'omx'

class Portfolio
  attr_reader :growth, :date, :stocks, :prices

  def initialize date=nil, stocks={}, growth=0, prices={}
    @date = date
    @stocks = stocks
    @growth = growth
    @prices = prices
  end

  def transaction date, ticker, quantity, price
    return self.class.new date, { ticker => quantity }, 1.0, { ticker => price } unless self.date

    period_growth = self.value(date: date, prices: {ticker => price}) / self.value
    stocks_after_transaction = stocks.merge({ticker => quantity}) {|key, before, added| before + added }

    self.class.new date, stocks_after_transaction, growth * period_growth, { ticker => price }
  end

  # Calculates the value of the enture portfolio.
  #
  # options - Used to redefine how value is calculated:
  #           :prices - a Hash of ticker plus price to override fetched prices from omx.
  #           :date   - calculate the value of a portfolio on a specific date.
  #
  # Returns nothing.
  def value(options={})
    actual_prices = options.fetch(:prices, {})
    actual_date = options.fetch(:date, date)
    value = 0
    @stocks.each do |ticker, quantity|
      price = actual_prices[ticker] || prices[ticker] || omx.closing_price(ticker, actual_date)
      value += quantity * price
    end
    value
  end

  private

  def omx
    @omx ||= Omx::Source.new
  end

end
