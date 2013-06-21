require 'support/spec_helper'
require 'omx/source'

describe Omx::Source do
  let(:omx) { Omx::Source.new }

  describe "#closing_price", vcr: true do

    it "fetches price for a specific date" do
      omx.closing_price("indu-c", "2011-08-11").should eql 138.50
    end

    it "fetches price for the last day of a year" do
      omx.closing_price("indu-c", "2011").should eql 129.50
    end

  end

end
