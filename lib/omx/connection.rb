module Omx
  class Connection

    def initialize
      @sess = Patron::Session.new
      @sess.base_url = "http://www.nasdaqomxnordic.com"
      @sess.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0a2) Gecko/20111101 Firefox/9.0a2'
      @sess.headers['X-Requested-With'] = 'XMLHttpRequest'
    end

    def post(instrument, from, to)
      @sess.headers['Referer'] = "http://www.nasdaqomxnordic.com/aktier/Historiska_kurser/?Instrument=#{instrument}"
      response = @sess.post("/webproxy/DataFeedProxy.aspx",
                            "xmlquery=#{payload(instrument, from, to)}",
                            {"Content-Type" => "application/x-www-form-urlencoded"})
      raise "unexpected http status code" unless response.status == 200

      response.body
    end

    private

    def payload(instrument, from, to)
      return <<END
<post>
<param name="SubSystem" value="History"/>
<param name="Action" value="GetDataSeries"/>
<param name="AppendIntraDay" value="no"/>
<param name="Instrument" value="#{instrument}"/>
<param name="FromDate" value="#{from}"/>
<param name="ToDate" value="#{to}"/>
<param name="hi__a" value="0,1,2,4,21,8,10,11,12,9"/>
<param name="ext_xslt" value="/nordicV3/hi_table_shares_adjusted.xsl"/>
<param name="ext_xslt_options" value=",undefined,"/>
<param name="ext_xslt_lang" value="sv"/>
<param name="ext_xslt_hiddenattrs" value=",ip,iv,"/>
<param name="ext_xslt_tableId" value="historicalTable"/>
<param name="app" value="/aktier/Historiska_kurser/"/>
</post>
END
    end

  end

end

