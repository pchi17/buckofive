class PollsController < ApplicationController
  before_action :logged_in_user?
  before_action :activated_current_user?

  def new
    @poll = current_user.polls.build
    @poll.choices.build(value: 'Yay')
    @poll.choices.build(value: 'Nay')
  end

  def create
    @poll = current_user.polls.build(poll_params)
    if @poll.save
      flash[:success] = 'your poll was created successfully'
      redirect_to poll_path(@poll)
    else
      render :new
    end
  end

  def index
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def destroy
  end

  private
    def poll_params
      params.require(:poll).permit(:content, choices_attributes: :value )
    end
end
