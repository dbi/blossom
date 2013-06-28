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

    it "defaults to today" do
      post = "<table id=\"historicalTable\" class=\"tablesorter\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\" name=\"_\">\r\n  <thead>\r\n    <tr>\r\n      <th title=\"Datum\">Datum</th>\r\n      <th title=\"H\xC3\xB6gsta kurs\">H\xC3\xB6gsta kurs</th>\r\n      <th title=\"L\xC3\xA4gsta kurs\">L\xC3\xA4gsta kurs</th>\r\n      <th title=\"St\xC3\xA4ngningskurs\">St\xC3\xA4ngn.kurs</th>\r\n      <th title=\"Average price\">Average price</th>\r\n      <th title=\"Total volym\">Tot. vol.</th>\r\n      <th title=\"Oms\xC3\xA4ttning\">Oms</th>\r\n      <th title=\"Antal avslut\">Avslut</th>\r\n    </tr>\r\n  </thead>\r\n  <tbody>\r\n    <tr id=\"historicalTable-\">\r\n      <td>2013-06-24</td>\r\n      <td>141,70</td>\r\n      <td>139,00</td>\r\n      <td>140,60</td>\r\n      <td>140,58</td>\r\n      <td>3 063 253</td>\r\n      <td>433 083 696</td>\r\n      <td>4 064</td>\r\n    </tr>\r\n    <tr id=\"historicalTable-\">\r\n      <td>2013-06-25</td>\r\n      <td>142,40</td>\r\n      <td>140,65</td>\r\n      <td>141,60</td>\r\n      <td>141,49</td>\r\n      <td>2 440 286</td>\r\n      <td>345 435 467</td>\r\n      <td>3 815</td>\r\n    </tr>\r\n    <tr id=\"historicalTable-\">\r\n      <td>2013-06-26</td>\r\n      <td>144,10</td>\r\n      <td>141,40</td>\r\n      <td>143,90</td>\r\n      <td>142,93</td>\r\n      <td>2 019 884</td>\r\n      <td>288 556 967</td>\r\n      <td>2 533</td>\r\n    </tr>\r\n    <tr id=\"historicalTable-\">\r\n      <td>2013-06-27</td>\r\n      <td>146,40</td>\r\n      <td>143,70</td>\r\n      <td>146,10</td>\r\n      <td>144,97</td>\r\n      <td>1 536 009</td>\r\n      <td>222 681 172</td>\r\n      <td>2 310</td>\r\n    </tr>\r\n  </tbody>\r\n</table>"
      Omx::Parser.should_receive(:new).with(post).and_return(stub(closing_price: nil))
      omx.closing_price("indu-c")
    end

  end

end
