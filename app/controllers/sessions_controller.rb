class SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.email.blank? || resource.login.blank?
      redirect_to resource, location: new_user_path
    else
      set_flash_message(:notice, :signed_in) if is_navigational_format?
      sign_in(resource_name, resource, force: true)
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end
end
