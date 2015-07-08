require 'koala'
require 'faker'
require 'mysql2'

oauth = Koala::Facebook::OAuth.new(899768646747265, 'a24d6671f94ce9eff9d79f39410df147')
token = oauth.get_app_access_token
graph = Koala::Facebook::API.new(token)

begin
  fb_api = Mysql2::Client.new(host:"localhost", username:"root", password:"password")
  fb_api.query("CREATE DATABASE IF NOT EXISTS test_results")
  fb_api = Mysql2::Client.new(host:"localhost", username:"root", password:"password", database:"test_results")
  fb_api.query("CREATE TABLE IF NOT EXISTS \
        Facebook_API(Name TEXT, Picture TEXT, Image TEXT)")
  fb_api.query("INSERT INTO Facebook_API(Name) VALUES('#{ graph.get_object('4?')['name']}')")
  fb_api.query("INSERT INTO Facebook_API(Picture) VALUES('#{graph.get_object('4/picture?width=800&height=800&redirect=false')['data']['url']}')")
  fb_api.query("INSERT INTO Facebook_API(Image) VALUES('#{Faker::Internet.email}')")
  results = fb_api.query("SELECT * FROM Facebook_API")
  results.each do |row|
    puts row["Name"]
    puts row["Picture"]
    puts row["Image"]
  end
end

