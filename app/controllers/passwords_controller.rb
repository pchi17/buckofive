class PasswordsController < ApplicationController
  before_action :logged_in_user?
  before_action :is_email_nil?

  def edit
  end

  def update
    if current_user.authenticate(params[:account][:oldpassword]) || current_user.account.password_digest.nil?
      if current_user.account.update_attributes(password_params)
        flash[:success] = 'password updated'
        return redirect_to edit_profile_password_path
      end
    else
      current_user.account.errors.add(:oldpassword, 'is incorrect')
    end
    render :edit
  end

  private
    def password_params
      params.require(:account).permit(:password, :password_confirmation)
    end

    def is_email_nil?
      if current_user.email.nil?
        store_location
        flash[:info] = 'please provide an Email first'
        redirect_to edit_profile_info_path
      end
    end
end
