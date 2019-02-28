class HomeController < ApplicationController
  def index
  end
  def aws_openam
    render html: Idp::Openam.new(current_user).aws_saml_assertion.body.html_safe
  end
end
