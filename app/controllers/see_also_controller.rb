class SeeAlsoController < ApplicationController
 
  def vote
    
    if not current_user
      render json_fail("No valid user session.")
    end
    
    id = (params[:id] || 0)
    sa = SeeAlso.find_by_id(id)
    
    # bad id passed
    if not sa
      render json_fail("Couldn't find that see also.")
    end
    
    # creator of see also is current user
    if sa.user == current_user
      render json_fail("You can't vote on your own see also.")
    end
    
    # current user already voted
    if sa.has_voted?(current_user)
      render json_fail("Current user has already voted.")
    end
    
    vote_action = params[:vote_action]
    # no vote action
    if not vote_action
      render json_fail("No vote action found.")
    end
    
    direction = (vote_action == "vote_up")    
    sa.votes << Vote.new(:vote => direction, :user => current_user)
    sa.save
    
    render :json => {:success => true, :vote_score => sa.vote_score}
  end
  
  def lookup
    l = params[:library]
    q = params[:term]
    version = Library.find_by_name_and_current(l, true).version rescue nil
    
    if not q
      render :json => []
    end
    
    name = q + "%"
    
    #@functions = Function.find(:all, :conditions => ['name like ? and version = ?', name, version]).sort{|a,b| Levenshtein.distance(q, a.name) <=> Levenshtein.distance(q, b.name)}.uniq
    @functions = Function.find(:all, :conditions => ['name ilike ? and version = ?', name, version]).uniq
    
    render :json => @functions.map{|f| {id: f.id, :href => f.href, :ns => f.ns.name, :name => f.name}}
  end
  
  def delete
    id = params[:id]
    
    if not id
      render json_fail "No see also specified to delete."
    end
    
    sa = SeeAlso.find_by_id(id)
    if not sa
      render json_fail "No see also found."
    end
    
    if not sa.user == current_user
      render json_fail "You don't own that see also."
    end
    
    if not sa.delete
      render json_fail "Unknown error deleting that see also."
    end
    
    render :json => {:success => true}
  end
  
  def add
    
    if not current_user
      render json_fail "Must be logged in to add see alsos."
    end
    
    id = params[:func]
    from_var = Function.find_by_id(id)
    
    if not from_var
      render json_fail "Couldn't find from var."
    end
       
    to_func_id = params[:see_also]
    if not to_func_id
      render json_fail "To var not specified."
    end
    
    #if see also already exists between the two vars
    if from_var.see_alsos.map(&:to_id).index(to_func_id)
      render json_fail "See also already exists."
    end

    if not to_var = Function.find(to_func_id)
      render json_fail "See also function doens't exist."
    end

    sa = SeeAlso.new(user:current_user, to_id: to_func_id, from_id: id)
    sa.save
    
    render :json => {
      :success => true, 
      :to_var => {
        :sa_id => sa.id, 
        :name => to_var.name, 
        :ns => to_var.ns.name, 
        :href => to_var.href, 
        :shortdoc => to_var.shortdoc
      },
      :content => render_to_string(:partial => "see_also_content", :locals => {:sa => sa})
    }
  end
end
