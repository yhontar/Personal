require 'koala'
require 'faker'
require 'mysql2'

oauth = Koala::Facebook::OAuth.new(899768646747265, 'a24d6671f94ce9eff9d79f39410df147')
token = oauth.get_app_access_token
$graph = Koala::Facebook::API.new(token)

def fill_sql(id_user)
  id_user = id_user.to_s
  avatar = id_user + '/picture?width=800&height=800&redirect=false'
  name = id_user + '?'
  begin
    $fb_api = Mysql2::Client.new(host:"localhost", username:"root", password:"password")
    $fb_api.query("CREATE DATABASE IF NOT EXISTS test_results")
    $fb_api = Mysql2::Client.new(host:"localhost", username:"root", password:"password", database:"test_results")
    $fb_api.query("CREATE TABLE IF NOT EXISTS \
          Facebook_API(
          id INT,
          Name TEXT,
          Picture TEXT,
          Email TEXT,
          PRIMARY KEY (id))")
    $fb_api.query("INSERT INTO Facebook_API
    SET
      id=#{id_user},
      Name='#{$graph.get_object(name)['name']}',
      Picture='#{$graph.get_object(avatar)['data']['url']}',
      Email='#{Faker::Internet.email}'
    ON DUPLICATE KEY UPDATE
      id=#{id_user},
      Name='#{$graph.get_object(name)['name']}',
      Picture='#{$graph.get_object(avatar)['data']['url']}',
      Email='#{Faker::Internet.email}'")
  end
end
def show
  results = $fb_api.query("SELECT * FROM Facebook_API")
  results.each do |row|
    puts row["id"]
    puts row["Name"]
    puts row["Email"]
    puts row["Picture"]
  end
end

fill_sql(4)
fill_sql(10)
fill_sql(4)
show
