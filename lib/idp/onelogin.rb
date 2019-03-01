class Idp::Onelogin

  def initialize(user = nil)
    @user = user
  end

  def email
    @user.try(:email)
  end

  def password
    @user.try(:encrypted_password)
  end

  def access_token
    uri = URI.parse("https://api.us.onelogin.com/auth/oauth2/token")
    res = Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Authorization"] = "client_id:#{ENV['ONELOGIN_CLIENT_ID']}, client_secret:#{ENV['ONELOGIN_CLIENT_SECRET']}"
      req["Content-Type"] = "application/json"
      req.body = {
        grant_type: "client_credentials"
      }.to_json
      http.request(req)
    end
    JSON.parse(res.body, { symbolize_names: true })[:data][0][:access_token]
  end

  def create_user
    uri = URI.parse("https://api.us.onelogin.com/api/1/users")
    Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      req.body = {
        firstname: email.split('@')[0],
        lastname: email.split('@')[1],
        email: email,
        username: email
      }.to_json
      http.request(req)
    end
    self
  end

  def assign_role
    uri = URI.parse("https://api.us.onelogin.com/api/1/users/#{user_id}/add_roles")
    Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Put.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      req.body = {
        role_id_array: [ ENV['ONELOGIN_ROLE_ID'].to_i ]
      }.to_json
      http.request(req)
    end
    self
  end

  def change_password
    uri = URI.parse("https://api.us.onelogin.com/api/1/users/set_password_clear_text/#{user_id}")
    Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Put.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      req.body = {
        password: password,
        password_confirmation: password
      }.to_json
      http.request(req)
    end
    self
  end

  def user_id
    uri = URI.parse("https://api.us.onelogin.com/api/1/users?email=#{email}")
    res = Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      http.request(req)
    end
    JSON.parse(res.body, { symbolize_names: true })[:data][0][:id]
  end

  def delete_user
    uri = URI.parse("https://api.us.onelogin.com/api/1/users/#{user_id}")
    Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Delete.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      http.request(req)
    end
    self
  end

  def aws_saml_assertion
    uri = URI.parse("https://api.us.onelogin.com/api/1/saml_assertion")
    res = Net::HTTP.start(uri.host, uri.port, { use_ssl: true }) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["Authorization"] = "bearer:#{access_token}"
      req["Content-Type"] = "application/json"
      req.body = {
        username_or_email: email,
        password: password,
        app_id: ENV['ONELOGIN_APP_ID'],
        subdomain: ENV['ONELOGIN_URI'].split('//')[1].split(".")[0]
      }.to_json
      http.request(req)
    end
    JSON.parse(res.body, { symbolize_names: true })[:data]
  end
end
