# encoding: UTF-8

require "omx/parser"

describe Omx::Parser do

  describe "#closing_price" do

    it "fetches the value from the closing price column" do
      Omx::Parser.new(<<END).closing_price.should eql 134.90
<table id="historicalTable" class="tablesorter" border="0" cellpadding="0" cellspacing="0" name="_">
  <thead>
    <tr>
      <th title="Datum">Datum</th>
      <th title="Högsta kurs">Högsta kurs</th>
      <th title="Lägsta kurs">Lägsta kurs</th>
      <th title="Stängningskurs">Stängn.kurs</th>
      <th title="Average price">Average price</th>
      <th title="Total volym">Tot. vol.</th>
      <th title="Omsättning">Oms</th>
      <th title="Antal avslut">Avslut</th>
    </tr>
  </thead>
  <tbody>
    <tr id="historicalTable-">
      <td>2012-01-02</td>
      <td>134,80</td>
      <td>129,00</td>
      <td>133,90</td>
      <td>132,63</td>
      <td>1 173 923</td>
      <td>155 700 410</td>
      <td>1 967</td>
    </tr>
    <tr id="historicalTable-">
      <td>2012-01-03</td>
      <td>135,90</td>
      <td>132,70</td>
      <td>135,70</td>
      <td>134,50</td>
      <td>2 180 204</td>
      <td>293 245 979</td>
      <td>3 785</td>
    </tr>
    <tr id="historicalTable-">
      <td>2012-01-04</td>
      <td>135,60</td>
      <td>133,90</td>
      <td>134,70</td>
      <td>134,64</td>
      <td>1 553 693</td>
      <td>209 193 448</td>
      <td>3 438</td>
    </tr>
    <tr id="historicalTable-">
      <td>2012-01-05</td>
      <td>135,40</td>
      <td>134,20</td>
      <td>134,90</td>
      <td>134,90</td>
      <td>568 078</td>
      <td>76 632 236</td>
      <td>1 162</td>
    </tr>
    <tr id="historicalTable-">
      <td>2012-01-06</td>
      <td></td>
      <td></td>
      <td>134,90</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>
END
    end

    it "fetches closing price from small output" do
      parser = Omx::Parser.new(<<END)
<table id="historicalTable" class="tablesorter" border="0" cellpadding="0" cellspacing="0" name="_">
  <thead>
    <tr>
      <th title="Datum">Datum</th>
      <th title="Högsta kurs">Högsta kurs</th>
      <th title="Lägsta kurs">Lägsta kurs</th>
      <th title="Stängningskurs">Stängn.kurs</th>
      <th title="Average price">Average price</th>
      <th title="Total volym">Tot. vol.</th>
      <th title="Omsättning">Oms</th>
      <th title="Antal avslut">Avslut</th>
    </tr>
  </thead>
  <tbody>
    <tr id="historicalTable-">
      <td>2012-01-02</td>
      <td>134,80</td>
      <td>129,00</td>
      <td>133,90</td>
      <td>132,63</td>
      <td>1 173 923</td>
      <td>155 700 410</td>
      <td>1 967</td>
    </tr>
  </tbody>
</talbe>
END
      parser.closing_price.should eql 133.90
    end

    it "fetches closing price for closed day" do
      parser = Omx::Parser.new(<<END)
<table id="historicalTable" class="tablesorter" border="0" cellpadding="0" cellspacing="0" name="_">
  <thead>
    <tr>
      <th title="Datum">Datum</th>
      <th title="Högsta kurs">Högsta kurs</th>
      <th title="Lägsta kurs">Lägsta kurs</th>
      <th title="Stängningskurs">Stängn.kurs</th>
      <th title="Average price">Average price</th>
      <th title="Total volym">Tot. vol.</th>
      <th title="Omsättning">Oms</th>
      <th title="Antal avslut">Avslut</th>
    </tr>
  </thead>
  <tbody>
    <tr id="historicalTable-">
      <td>2012-01-06</td>
      <td></td>
      <td></td>
      <td>134,90</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</talbe>
END
      parser.closing_price.should eql 134.90
    end

    it "crashes on invalid data" do
      parser = Omx::Parser.new(<<END)
<table id="historicalTable" class="tablesorter" border="0" cellpadding="0" cellspacing="0" name="_">
  <thead>
    <tr>
      <th title="Datum">Datum</th>
      <th title="Högsta kurs">Högsta kurs</th>
      <th title="Lägsta kurs">Lägsta kurs</th>
      <th title="Stängningskurs">Stängn.kurs</th>
      <th title="Average price">Average price</th>
      <th title="Total volym">Tot. vol.</th>
      <th title="Omsättning">Oms</th>
      <th title="Antal avslut">Avslut</th>
    </tr>
  </thead>
</talbe>
END
      expect { parser.closing_price }.to raise_error RuntimeError
    end

    it "crashes on invalid price data" do
      parser = Omx::Parser.new(<<END)
<table id="historicalTable" class="tablesorter" border="0" cellpadding="0" cellspacing="0" name="_">
  <thead>
    <tr>
      <th title="Datum">Datum</th>
      <th title="Högsta kurs">Högsta kurs</th>
      <th title="Lägsta kurs">Lägsta kurs</th>
      <th title="Stängningskurs">Stängn.kurs</th>
      <th title="Average price">Average price</th>
      <th title="Total volym">Tot. vol.</th>
      <th title="Omsättning">Oms</th>
      <th title="Antal avslut">Avslut</th>
    </tr>
  </thead>
  <tbody>
    <tr id="historicalTable-">
      <td>2012-01-06</td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</talbe>
END
      expect { parser.closing_price }.to raise_error RuntimeError
    end

  end

end
