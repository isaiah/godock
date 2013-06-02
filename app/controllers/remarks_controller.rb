class RemarksController < ApplicationController
  def create 
    user_id = user_signed_in? ? current_user.id : 1
    @remark = Remark.new(params[:remark].merge(:user_id => user_id))
    @remark.source_url = request.env['HTTP_REFERER']
    if @remark.save
      respond_to do |format|
        format.js
      end
    end
  end
end
