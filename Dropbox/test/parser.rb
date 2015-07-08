require 'nokogiri'
require 'open-uri'
require 'mysql2'

page = Nokogiri::HTML(open('http://www.bbc.com/news'))
#File.new "/home/vlad/out.txt", "w"
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
  result = Mysql2::Client.new(host:"localhost", username:"root", password:"iamyourfather")
  result.query("CREATE DATABASE IF NOT EXISTS test_results")
  result = Mysql2::Client.new(host:"localhost", username:"root", password:"iamyourfather", database:"test_results")
  result.query("CREATE TABLE IF NOT EXISTS \
        Result(Title TEXT, Summary TEXT, Image TEXT, Date TEXT)")
  $titles.each {|title| result.query("INSERT INTO Result(Title) VALUES('#{title.text.delete(?').tr ' ', ?_}')")}
  $images.each {|image| result.query("INSERT INTO Result(Image) VALUES('#{image['data-src']}')")}
  $descriptions.each {|descr| result.query("INSERT INTO Result(Summary) VALUES(\"#{descr.text}\")")}
  $dates.each {|date| result.query("INSERT INTO Result(Date) VALUES('#{date.text}')")}
  results = result.query("SELECT * FROM Result")
  results.each do |row|
    puts row["Title"]
    puts row["Desritption"]
    puts row["Image"]
    puts row["Date"]
  end
end

