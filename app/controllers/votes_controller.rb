class VotesController < ApplicationController
  before_action :logged_in_user?
  before_action :activated_current_user?

  def create
    @poll = Poll.find(params[:poll_id])
    unless choice = @poll.choices.find_by(id: params[:choice_id])
      respond_to do |format|
        format.html do
          flash[:danger] = 'you must select a choice'
          return redirect_to @poll
        end
        format.js { render json: nil }
      end
    else
      # I have not decided whether users should be allowed to choose more than 1 choice for each poll
      # if I decided so, I will just add poll_id to votes table and place a unique contraint on the
      # combination of poll_id and user_id. For now I'll wrap voting in a serializable transaction
      # to ensure that users can only vote once.
      User.transaction(isolation: :serializable) do
        unless @poll.voted_by?(current_user)
          current_user.votes.create(choice: choice)
        end
      end
      respond_to do |format|
        format.html { redirect_to @poll }
        format.js   { @poll.reload }
      end
    end
  end
end
