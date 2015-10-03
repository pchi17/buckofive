class ProfilesController < ApplicationController
  before_action :logged_in_user?

  def show
    @polls = Poll.filter_by(current_user, params[:filter]).search(params[:search_term], sort_column, sort_direction, params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
