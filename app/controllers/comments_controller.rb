class CommentsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @comment = current_user.comments.new(params[:comment])

    @comment.save
    redirect_to @comment.commentable.href
  end

  def update
    @comment = current_user.comments.find(params[:comment_id])
    if @comment
      @comment.body = params[:comment][:body]
    end
    @comment.save
    redirect_to @comment.commentable.href
  end
  
  def destroy
    flash[:message] = "There was a problem deleting that comment."
    if @example = current_user.comments.find(params[:id]) && @example.delete
      flash[:message] = "Comment successfully deleted."
    end
    
    redirect_back_or_default "/"
  end
  
end
