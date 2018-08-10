require "oauth2"
require "yaml"
require "base64"

desc ""
task :default do
  config = load_config

  client = OAuth2::Client.new(
    config["yapi"]["client_id"],
    config["yapi"]["client_secret"],
    {
      site: "https://api.login.yahoo.com",
      authorize_url: "/oauth2/request_auth",
      token_url: "/oauth2/get_token"
    }
  )

  puts "Go here: #{client.auth_code.authorize_url(redirect_uri: "oob")}"
  print "Place code here: "

  auth_code = STDIN.gets.strip

  token = client.auth_code.get_token(
    auth_code,
    redirect_uri: "http://localhost:8080/oauth2/callback"
  )
  puts token

  response = token.get("https://fantasysports.yahooapis.com/fantasy/v2/league/#{config["league_keys"]["2014"]}")
  puts response
end

def load_config
  YAML.load_file("config.yml")
end


def auth

end
