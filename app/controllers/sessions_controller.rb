class SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(:user, resource, bypass: true)
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end
