class SessionsController < Devise::SessionsController
  def create
    super
    sign_in(resource, bypass:true)
  end
end
