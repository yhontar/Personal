require 'koala'
require 'faker'
require 'mysql'

#token = 'https://graph.facebook.com/oauth/access_token?client_id=899768646747265&client_secret=a24d6671f94ce9eff9d79f39410df147&grant_type=client_credentials'
oauth = Koala::Facebook::OAuth.new(899768646747265, 'a24d6671f94ce9eff9d79f39410df147')
token = oauth.get_app_access_token
graph = Koala::Facebook::API.new(token)
user = graph.get_object('4?')
pic = graph.get_object('4/picture?width=800&height=800&redirect=false')['data']

begin
  fb_api = Mysql.new 'localhost', 'user', 'password', 'test_ruby'
  fb_api.query("CREATE TABLE IF NOT EXISTS \
        Facebook_API(Name TEXT, Picture TEXT, Image TEXT)")
  fb_api.query("INSERT INTO Facebook_API(Name) VALUES('#{user['name']}')")
  fb_api.query("INSERT INTO Facebook_API(Picture) VALUES('#{pic['url']}')")
  fb_api.query("INSERT INTO Facebook_API(Image) VALUES(\"#{Faker::Internet.email}\")")
  rs = fb_api.query("SELECT * FROM   Facebook_API")
  n_rows = rs.num_rows
  n_rows.times {puts rs.fetch_row.join("\s")}
end
