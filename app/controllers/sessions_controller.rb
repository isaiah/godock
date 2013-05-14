class SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.email.blank? || resource.login.blank?
      redirect_to new_user_path(identity_url: resource.identity_url)
    else
      sign_in(:user, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
      #set_flash_message(:notice, :signed_in) if is_navigational_format?
      #sign_in(:user, resource)
      #redirect_to 
    end
  end
end
