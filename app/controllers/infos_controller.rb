class InfosController < ApplicationController
  before_action :logged_in_user?

  def edit
  end

  def update
    if current_user.update_attributes(info_params)
      flash[:success] = 'account updated'
      friendly_forward_or edit_profile_info_path
    else
      render :edit
    end
  end

  private
    def info_params
      params.require(:user).permit(:name, :email)
    end
end
