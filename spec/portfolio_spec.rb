require 'portfolio'
require 'omx'
require 'webmock'
WebMock.disable_net_connect!

describe Portfolio do

  describe "#value" do

    it "fetches the stock prices" do
      Omx::Source.any_instance.should_receive(:closing_price).with("indu-c", "2011-01-01").and_return(118.2)
      p = Portfolio.new "2011-01-01", { "indu-c" => 1000 }
      p.value.should eql 1000 * 118.2
    end

    it "use price from #initialize instead of fetching if available" do
      Omx::Source.any_instance.should_not_receive(:closing_price)
      p = Portfolio.new "2011-01-01", { "indu-c" => 1000 }, 1, { "indu-c" => 99.99 }
      p.value.should eql 1000 * 99.99
    end

    it "use explicit price from #value instead of fetching if available" do
      Omx::Source.any_instance.should_not_receive(:closing_price)
      p = Portfolio.new "2011-01-01", { "indu-c" => 1000 }
      p.value(prices: { "indu-c" => 88.88 }).should eql 1000 * 88.88
    end

    it "fetches the stock prices for an explicit date" do
      Omx::Source.any_instance.should_receive(:closing_price).with("indu-c", "2011-02-02").and_return(77.77)
      p = Portfolio.new "2011-01-01", { "indu-c" => 1000 }
      p.value(date: "2011-02-02").should eql 1000 * 77.77
    end

  end

  describe "#transaction" do
    let(:portfolio) { Portfolio.new }

    it "returns a new portfolio" do
      portfolio.transaction("2001-01-01", "indu-c", 1000, 118.2).should_not eql portfolio
    end

    it "calculates growth for one stock" do
      portfolio.transaction("2011-01-01", "indu-c", 1000, 92).
        transaction("2011-01-02", "indu-c", 1000, 101.2).
        growth.should eql 1.1
    end

  end

  describe "#dividend" do

  end

end

