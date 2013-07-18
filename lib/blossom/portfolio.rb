require 'omx'

class Portfolio
  attr_reader :date, :stocks, :prices

  def initialize date=nil, stocks={}, growth=0, prices={}
    @date = date
    @stocks = stocks
    @growth = growth
    @prices = prices
    # i can validate the portfolio here without cluttering the transaction method etc.
  end

  def transaction date, ticker, quantity, price
    return self.class.new date, { ticker => quantity }, 1.0, { ticker => price } unless self.date

    value_at_start = self.value
    value_at_end = self.value(date: date, prices: {ticker => price})
    period_growth =  value_at_end / value_at_start
    stocks_after_transaction = stocks.merge({ticker => quantity}) {|key, before, added| before + added }
    self.class.new date, stocks_after_transaction, growth * period_growth, { ticker => price }
  end

  def dividend date, ticker, amount
    value_after_dividends = self.value(date: date, prices: {}) + stocks[ticker] * amount
    period_growth = value_after_dividends / self.value

    Portfolio.new date, stocks, growth * period_growth
  end

  # Calculates the value of the enture portfolio.
  #
  # options - Used to redefine how value is calculated:
  #           :prices - a Hash of ticker plus price to override fetched prices from omx.
  #           :date   - calculate the value of a portfolio on a specific date.
  #
  # Returns nothing.
  def value(options={})
    actual_prices = options.fetch(:prices, prices)
    actual_date = options.fetch(:date, date)
    value = 0
    stocks.each do |ticker, quantity|
      price = actual_prices[ticker] || omx.closing_price(ticker, actual_date)
      value += quantity * price
    end
    value
  end

  def growth(date=nil)
    if date
      @growth * self.value(date: date, prices: {}) / self.value # TODO: that we need to send in prices here is brittle
    else
      @growth
    end
  end

  private

  def omx
    @omx ||= Omx::Source.new
  end

end
