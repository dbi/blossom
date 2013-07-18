require 'webmock'
require 'blossom/portfolio'

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

    it "calculates values for multiple stocks" do
      Omx::Source.any_instance.should_receive(:closing_price).with("indu-c", "2011-02-02").and_return(20.05)
      Omx::Source.any_instance.should_receive(:closing_price).with("hm-b", "2011-02-02").and_return(10.15)
      p = Portfolio.new "2011-01-01", { "indu-c" => 100, "hm-b" => 100 }
      p.value(date: "2011-02-02").should eql 3020.0
    end

    it "ignores all explicit from #initialize of available in #value" do
      Omx::Source.any_instance.should_receive(:closing_price).with("hm-b", "2011-02-02").and_return(10.15)
      p = Portfolio.new "2011-01-01", { "indu-c" => 100, "hm-b" => 100 }, 1.0, { "hm-b" => 90.0 }
      p.value(date: "2011-02-02", prices: { "indu-c" => 100.0 }).should eql 11015.0
    end

  end

  describe "#growth" do
    let(:portfolio) { Portfolio.new }

    it "calculates growth to the current date" do
      Omx::Source.any_instance.should_receive(:closing_price).with("indu-c", "2011-01-02").and_return(101.2)
      portfolio.transaction("2011-01-01", "indu-c", 1000, 92).
        transaction("2011-01-02", "hm-b", 1000, 130.0).
        growth.should eql 1.1
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

    it "calculates growth for multiple stocks" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-02").and_return(92.0)
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-03").and_return(101.2)
      Omx::Source.any_instance.stub(:closing_price).with("hm-b", "2011-01-03").and_return(145.2)
      portfolio.transaction("2011-01-01", "indu-c", 1000, 92.0).
        transaction("2011-01-02", "hm-b", 1000, 132).
        growth("2011-01-03").should eql 1.1
    end

    it "calculates growth for reinvestments" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-03").and_return(121.44)
      portfolio.transaction("2011-01-02", "indu-c", 1000, 92.0).
        transaction("2011-01-03", "indu-c", 1000, 101.2).
        growth("2011-01-03").should eql 1.32
    end

    it "calculates growth after sales" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-03").and_return(121.44)
      portfolio.transaction("2011-01-02", "indu-c", 1000, 92.0).
        transaction("2011-01-03", "indu-c", -200, 101.2).
        growth("2011-01-03").should eql 1.32
    end

  end

  describe "#dividend" do
    let(:portfolio) { Portfolio.new }

    it "calculates growth including dividends" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-02").and_return(110.00)
      portfolio.transaction("2011-01-01", "indu-c", 1000, 100.0).
        dividend("2011-01-02", "indu-c", 4.5).
        growth.should eql 1.145
    end

    it "calculates growth after dividend" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-02").and_return(110.00)
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-03").and_return(121.00)
      portfolio.transaction("2011-01-01", "indu-c", 1000, 100.0).
        dividend("2011-01-02", "indu-c", 4.5).
        growth("2011-01-03").should eql 1.2595
    end

    it "calculates growth after multiple dividends" do
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-02").and_return(110.00)
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-03").and_return(121.00)
      Omx::Source.any_instance.stub(:closing_price).with("indu-c", "2011-01-04").and_return(121.00)
      portfolio.transaction("2011-01-01", "indu-c", 1000, 100.0).
        dividend("2011-01-02", "indu-c", 4.5).
        dividend("2011-01-03", "indu-c", 4.5).
        growth("2011-01-04").should eql 1.306340909090909
    end

  end

end

