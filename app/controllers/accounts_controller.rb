class AccountsController < ApplicationController
  before_action :logged_in_user?

  def edit
  end

  def update
    current_user.skip_password_validation = true
    if current_user.update_attributes(user_params)
      flash[:success] = 'account updated'
      friendly_forward_or edit_profile_account_path
    else
      render :edit
    end
  end
end
