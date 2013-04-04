class UsersController < ApplicationController
  def profile
    
    @user = User.find_by_login(params[:login])
   
    if not @user
      render :template => 'public/404.html', :layout => false, :status => 404
    end
    
    examples = @user.examples
    examples_map = @user.examples.reduce({}) {|coll, e| coll.merge({e.function_id => e})}
    Example.find_by_sql(["select * from example_versions where user_id = ?", @user.id]).each do |e|
      if not examples_map[e.function_id]
        examples << e
        examples_map = examples_map.merge({e.function_id => e})
      end
    end
        
    @recent = (@user.comments + examples + @user.see_alsos).uniq.sort{|a,b| b.updated_at <=> a.updated_at}
  end

  def new
    @user = User.find_by_identity_url(params[:identity_url])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      sign_in(resource, bypass: true)
      redirect_to root_path
    else
      render "new"
    end
  end
end
