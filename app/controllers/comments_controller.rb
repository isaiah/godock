class CommentsController < ApplicationController
  def create
    @function = Function.find(params[:func_id])
    @comment = Comment.build_from(@function, current_user.id, params[:comment][:body])
    @comment.title = params[:comment][:title]
    @comment.subject = params[:comment][:subject]

    @comment.save
    redirect_to @function.href
  end

  def update
    @function = Function.find(params[:func_id])
    @comment = Comment.find(params[:comment_id])
    if @comment and @comment.user_id == current_user.id
      @comment.body = params[:comment][:body]
    end
    @comment.save
    redirect_to @function.href
  end
  
  def delete
    
    flash[:message] = "There was a problem deleting that comment."
    
    if current_user
      @example = Comment.find_by_id_and_user_id(params[:id], current_user.id)
      if @example
        if @example.delete
          flash[:message] = "Comment successfully deleted."
        end
      end
    end
    
    redirect_back_or_default "/"
  end
  
end
