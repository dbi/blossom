require 'blossom'

my_growth = Blossom::Portfolio.new.
  transaction("2010-06-23", "indu-c", 1000, 92.0).
  transaction("2010-11-11", "hm-b", 244, 230.1).
     dividend("2011-05-08", "hm-b", 9.50).
     dividend("2011-05-13", "indu-c", 4.00).
  transaction("2011-07-05", "indu-c", 300, 105.5).
  transaction("2011-08-10", "hm-b", 300, 192.8).
     dividend("2012-05-08", "hm-b", 9.50).
     dividend("2012-05-09", "indu-c", 4.50).
  growth(Time.now.to_date.to_s)

index_growth = Blossom::Portfolio.new.
  transaction("2010-06-23", "omx-stockholm-30-gi", 1, 128.02).
  growth(Time.now.to_date.to_s)

puts "mine:  %.2f" % my_growth
puts "index: %.2f" % index_growth
days = (DateTime.now - DateTime.new(2010,06,23)).to_i
annual_growth = ((my_growth/1)**(1.0/days))**365
puts "annual growth is %.2f%" % ((annual_growth-1)*100)
