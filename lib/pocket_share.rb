require "net/http"
require "net/https"

class PocketShare
  def self.get_request_token(host, app)
    uri = URI.parse("https://getpocket.com/v3/oauth/request")
    post_request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json" })
    post_request.body = {
      :consumer_key => app.consumer_key,
      :redirect_uri => self.redirect_uri(host, app),
    }.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    post_response = http.request(post_request)
    json_response = JSON.parse(post_response.body)
    json_response["code"]
  end

  def self.get_access_token(app, request_token)
    uri = URI.parse("https://getpocket.com/v3/oauth/authorize")
    post_request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json; charset=UTF-8", "X-Accept" => "application/json" })
    post_request.body = {
      :consumer_key => app.consumer_key,
      :code => request_token,
    }.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    post_response = http.request(post_request)
    JSON.parse(post_response.body)
  end

  def self.share(app, token, item)
    uri = URI.parse("https://getpocket.com/v3/add")
    post_request = Net::HTTP::Post.new(uri.path, {"Content-Type" => "application/json; charset=UTF-8"})
    post_request.body = {
      :url => URI.encode_www_form_component(item.url),
      :title => URI.encode_www_form_component(item.title),
      :consumer_key => app.consumer_key,
      :access_token => token.token,
    }.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    post_response = http.request(post_request)
    JSON.parse(post_response.body)
  end

  def self.redirect_uri(host, app)
    "http://#{host}/sharing/#{app.app}/finish"
  end
end
