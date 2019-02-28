class Idp::Openam

  DEFAULT_URL = 'http://localhost:3000/openam'

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
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/json/authenticate?realm=/")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req["X-OpenAM-Username"] = ENV["OPENAM_ADMIN_USER"] || "amAdmin"
    req["X-OpenAM-Password"] = ENV["OPENAM_ADMIN_PASS"] || "password"
    req["Content-Type"] = "application/json"
    res = http.request(req)
    JSON.parse(res.body, { symbolize_names: true })[:tokenId]
  end

  def token_id
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/json/authenticate?realm=/")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req["X-OpenAM-Username"] = email
    req["X-OpenAM-Password"] = password
    req["Content-Type"] = "application/json"
    res = http.request(req)
    JSON.parse(res.body, { symbolize_names: true })[:tokenId]
  end

  def create_user
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/json/users/?_action=create")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req["iplanetDirectoryPro"] = admin_token_id
    req["Content-Type"] = "application/json"
    payload = {
      username: email,
      userpassword: password,
      mail: email,
      employeeNumber: "#{ENV["OPENAM_AWS_ROLE_ARN"]},#{ENV["OPENAM_AWS_ID_PROVIDER_ARN"]}"
    }.to_json
    req.body = payload
    http.request(req)
  end

  def change_password
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/json/users/#{email}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Put.new(uri.request_uri)
    req["iplanetDirectoryPro"] = admin_token_id
    req["Content-Type"] = "application/json"
    payload = {
      username: email,
      userpassword: password
    }.to_json
    req.body = payload
    http.request(req)
  end

  def delete_user
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/json/users/#{email}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Delete.new(uri.request_uri)
    req["iplanetDirectoryPro"] = admin_token_id
    req["Content-Type"] = "application/json"
    http.request(req)
  end

  def aws_saml_assertion
    uri = URI.parse("#{ENV["OPENAM_URI"] || DEFAULT_URL}/saml2/jsp/idpSSOInit.jsp?metaAlias=/idp&spEntityID=urn:amazon:webservices")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.request_uri)
    req["Cookie"] = "iPlanetDirectoryPro=#{token_id}"
    http.request(req)
  end
end
