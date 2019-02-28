class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super

    Idp::Openam.new(resource).create_user if resource.errors.count.zero?
  end

  def update
    super

    Idp::Openam.new(resource).change_password if resource.errors.count.zero?
  end

  def destroy
    super

    Idp::Openam.new(resource).delete_user if resource.errors.count.zero?
  end
end
