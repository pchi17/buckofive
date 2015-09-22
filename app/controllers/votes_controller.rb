class VotesController < ApplicationController
  before_action :logged_in_user?
  before_action :activated_current_user?

  def create
    choice = Choice.find(params[:vote][:choice_id])
    current_user.votes.create(choice_id: choice.id)
    @poll  = choice.poll

    respond_to do |format|
      format.html { redirect_to @poll }
      format.js
    end
  end
end
