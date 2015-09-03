class AccountActivationsController < ApplicationController
  before_action :logged_in_user, only: [:create]
  before_action :correct_user,   only: [:create]

  def create
    @user.send_activation_email
    flash[:info] = 'activation Email sent'
    redirect_back_or(edit_user_path(@user))
  end

  def edit
    if @user = User.find_by(email: params[:email])
      if @user.activated?
        flash[:info] = 'your account is already activated'
        return redirect_to root_path
      end

      if @user.is_digest?(:activation, params[:id])
        @user.activate_account
        flash[:success] = 'account activated'
        return redirect_to root_path
      end
    end

    flash[:danger] = 'invalid activation link'
    redirect_to root_path
  end
end
