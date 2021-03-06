# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def after_sign_in_path_for(resource)
    sign_in_url = url_for(:action => 'new', :controller => 'sessions', :only_path => false, :protocol => 'http')
    if request.referer == sign_in_url
      super
    else
      stored_location_for(resource) || request.referer || root_path
    end
  end
  private
  
  def json_fail(message)
    return {:json => {:success => false, :message => message}}
  end
  
  def redirect_back_or_default(path)
    redirect_to :back
    rescue ActionController::RedirectBackError
    redirect_to path
  end
  
  def find_recently_updated(size, lib = nil)
    recent = []
    
    comments = []
    examples = []
    see_alsos = []
    
    if not lib
      comments = Comment.find(:all, :limit => size, :order => 'updated_at DESC')
      examples = Example::Version.order("updated_at desc").limit(size)
      see_alsos = SeeAlso.find(:all, :limit => size, :order => 'updated_at DESC')
    else
      
       comments = Comment.find(:all, 
        :joins => "INNER JOIN functions ON comments.commentable_id = functions.id LEFT JOIN namespaces ON functions.namespace_id = namespaces.id LEFT JOIN libraries ON namespaces.library_id = libraries.id",
        :conditions => ["libraries.name = ?", lib],
        :limit => size, 
        :order => 'updated_at DESC')
        
       examples = Example.find(:all, 
          :include => [:function, {:function => :namespace}, {:function => {:namespace => :library}}],
          :conditions => {:functions => {:namespaces => {:libraries => {:name => lib}}}},
          :limit => size, 
          :order => 'examples.updated_at DESC')
      
       see_alsos = SeeAlso.find(:all, 
          :include => [:from_function, {:from_function => :namespace}, {:from_function => {:namespace => :library}}],
          :conditions => {:from_functions => {:namespaces => {:libraries => {:name => lib}}}},
          :limit => size, 
          :order => 'see_alsos.updated_at DESC')  
    end
    
    recent = (comments + examples + see_alsos).sort{|a,b| b.updated_at <=> a.updated_at}
      
    if recent.size > size
      recent = recent[0, size]
    end
    
    recent
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end
  
end
