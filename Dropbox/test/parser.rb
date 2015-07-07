require 'nokogiri'
require 'open-uri'
require 'mysql'

page = Nokogiri::HTML(open('http://www.bbc.com/news'))

items = page.css('.distinct-component-group').collect {|block| block}

items.each  do |part| 
  if part.css('.group-title').text.include? "Features & Analysis" then
    $titles = part.css('.title-link__title-text')
    $dates = part.css('.mini-info-list__item .date.date--v2')
    $descriptions = part.css('.sparrow-item__summary')
    $images = part.css('.js-delayed-image-load')
  end
end

begin 
  result = Mysql.new 'localhost', 'user', 'password', 'parse_result'
  result.query("CREATE TABLE IF NOT EXISTS \
        Result(Title TEXT, Summary TEXT, Image TEXT, Date TEXT)")
  $titles.each {|title| result.query("INSERT INTO Result(Title) VALUES('#{title.text}')")}
  $images.each {|image| result.query("INSERT INTO Result(Image) VALUES('#{image['data-src']}')")}
  $descriptions.each {|descr| result.query("INSERT INTO Result(Summary) VALUES(\"#{descr.text}\")")}
  $dates.each {|date| result.query("INSERT INTO Result(Date) VALUES('#{date.text}')")}
  rs = result.query("SELECT * FROM Result")
  n_rows = rs.num_rows        
  n_rows.times {puts rs.fetch_row.join("\s")}
end
