class HomeController < ApplicationController
  def index
  end
  def aws_openam
    render html: Idp::Openam.new(current_user).aws_redirect_html.body.html_safe
  end
  def aws_onelogin
    @saml_assertion = Idp::Onelogin.new(current_user).aws_saml_assertion
    render layout: nil
  end
end
