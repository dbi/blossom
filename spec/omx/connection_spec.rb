require 'support/spec_helper'
require 'omx/connection'

describe Omx::Connection do

  describe "#post" do

    it "fakes a browser request", vcr: { cassette_name: 'fake_browser' } do
      connection = Omx::Connection.new
      connection.post("SSE3966", "2012-01-01", "2012-01-08")
      sess = connection.instance_variable_get(:@sess)
      sess.headers.should eql({"User-Agent"=> "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0a2) Gecko/20111101 Firefox/9.0a2",
                               "X-Requested-With"=>"XMLHttpRequest",
                               "Referer"=> "http://www.nasdaqomxnordic.com/aktier/Historiska_kurser/?Instrument=SSE3966"})
    end

    it "raises exceptions on unexpected http status codes" do
      stub_request(:post, "http://www.nasdaqomxnordic.com/webproxy/DataFeedProxy.aspx").to_return(:status => [500, "Internal Server Error"])
      connection = Omx::Connection.new
      expect { connection.post("invalid", "2012-01-01", "2012-01-08") }.to raise_error RuntimeError
    end

  end

end
