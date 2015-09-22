class PasswordsController < ApplicationController
  before_action :logged_in_user?

  def edit
  end

  def update
    unless current_user.authenticate(params[:user][:oldpassword])
      current_user.errors.add(:oldpassword, 'is incorrect')
      render :edit
    else
      update_current_user('password updated', edit_profile_password_path)
    end
  end
end
