class UsersController < ApplicationController

  def profile
    @user = User.find_by_login(params[:login])
    if not @user
      render :template => 'public/404.html', :layout => false, :status => 404
    end
    
    @recent = (@user.comments + @user.examples + @user.see_alsos).uniq.sort{|a,b| b.updated_at <=> a.updated_at}
  end

  def new
    @user = User.find_by_identity_url(params[:identity_url])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      sign_in(@user, bypass: true)
      redirect_to root_path
    else
      render "new"
    end
  end
end
