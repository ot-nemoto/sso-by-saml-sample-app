class Idp::Openam

  def initialize(user = nil)
    @user = user
  end

  def email
    @user.try(:email)
  end

  def password
    @user.try(:encrypted_password)
  end

  def admin_token_id
    token_id(ENV["OPENAM_ADMIN_USER"], ENV["OPENAM_ADMIN_PASS"])
  end

  def token_id(email = self.email, password = self.password)
    uri = URI.parse("#{ENV["OPENAM_URI"]}/json/authenticate?realm=/")
    res = Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["X-OpenAM-Username"] = email
      req["X-OpenAM-Password"] = password
      req["Content-Type"] = "application/json"
      http.request(req)
    end
    JSON.parse(res.body, { symbolize_names: true })[:tokenId]
  end

  def create_user
    uri = URI.parse("#{ENV["OPENAM_URI"]}/json/users/?_action=create")
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Post.new(uri.request_uri)
      req["iplanetDirectoryPro"] = admin_token_id
      req["Content-Type"] = "application/json"
      req.body = {
        username: email,
        userpassword: password,
        mail: email,
        employeeNumber: "#{ENV["OPENAM_AWS_ROLE_ARN"]},#{ENV["OPENAM_AWS_ID_PROVIDER_ARN"]}"
      }.to_json
      http.request(req)
    end
    self
  end

  def change_password
    uri = URI.parse("#{ENV["OPENAM_URI"]}/json/users/#{email}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Put.new(uri.request_uri)
      req["iplanetDirectoryPro"] = admin_token_id
      req["Content-Type"] = "application/json"
      req.body = {
        username: email,
        userpassword: password
      }.to_json
      http.request(req)
    end
    self
  end

  def delete_user
    uri = URI.parse("#{ENV["OPENAM_URI"]}/json/users/#{email}")
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Delete.new(uri.request_uri)
      req["iplanetDirectoryPro"] = admin_token_id
      req["Content-Type"] = "application/json"
      http.request(req)
    end
    self
  end

  def aws_redirect_html
    uri = URI.parse("#{ENV["OPENAM_URI"]}/saml2/jsp/idpSSOInit.jsp?metaAlias=/idp&spEntityID=urn:amazon:webservices")
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Cookie"] = "iPlanetDirectoryPro=#{token_id}"
      http.request(req)
    end
  end
end
