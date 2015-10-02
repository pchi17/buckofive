class CommentsController < ApplicationController
  before_action :logged_in_user?
  before_action :activated_current_user?

  def create
    @poll    = Poll.find(params[:poll_id])
    @comment = current_user.comments.build(comment_params.merge(poll: @poll))
    respond_to do |format|
      if @comment.save
        format.html { redirect_to @poll }
        format.js
      else
        format.html { render :'polls/show' }
        format.js   { render :new }
      end
    end
  end

  def destroy
    @poll    = Poll.find(params[:poll_id])
    @comment = @poll.comments.find(params[:id])
    respond_to do |format|
      if @comment.created_by?(current_user) || current_user.admin?
        @comment.delete
        format.html { redirect_to @poll }
        format.js
      else
        format.html { redirect_to @poll }
        format.js   { render json: nil }
      end
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:content)
    end
end
