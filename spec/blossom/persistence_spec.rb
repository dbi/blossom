require 'blossom/redis_persistence'

describe Blossom::RedisPersistence do

  describe "#store" do

    it "stores new values" do
      Redis.any_instance.should_receive(:get).with("blossom-ticker-date").and_return(nil)
      Redis.any_instance.should_receive(:set).with("blossom-ticker-date", "price")
      subject.store("ticker", "date") { |ticker, date| "price" }
    end

    it "fetches stored values" do
      Redis.any_instance.should_receive(:get).with("blossom-ticker-date").and_return("fetched_price")
      Redis.any_instance.should_not_receive(:set)
      subject.store("ticker", "date") { |ticker, date| "price" }.should eql "fetched_price"
    end

  end

end
