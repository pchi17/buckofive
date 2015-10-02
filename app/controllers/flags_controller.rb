class FlagsController < ApplicationController
  before_action :logged_in_user?
  before_action :activated_current_user?, only: :create
  before_action :admin_user?,             only: :index

  def create
    poll = Poll.find(params[:poll_id])
    poll.increment!(:flags)
    AdminMailer.send_flag_notification(poll)
    respond_to do |format|
      format.html do
        flash[:info] = 'poll flagged'
        redirect_to poll
      end
      format.js
    end
  end

  def index
    @polls = Poll.flagged
  end
end
