class VotesController < ApplicationController
  def create
    poll = Poll.includes(:choices).find(params[:poll_id])
    choice = poll.choices.find(params[:vote][:choice_id])
    current_user.votes.create(choice_id: choice.id)
    redirect_to poll
  end
end
