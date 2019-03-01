class Users::RegistrationsController < Devise::RegistrationsController

  def create
    super

    if resource.errors.count.zero?
      Idp::Openam.new(resource).create_user
      Idp::Onelogin.new(resource).create_user.assign_role.change_password
    end
  end

  def update
    super

    if resource.errors.count.zero?
      Idp::Openam.new(resource).change_password
      Idp::Onelogin.new(resource).change_password
    end
  end

  def destroy
    super

    if resource.errors.count.zero?
      Idp::Openam.new(resource).delete_user
      Idp::Onelogin.new(resource).delete_user
    end
  end
end
