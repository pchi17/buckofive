class AccountActivationsController < ApplicationController
  before_action :logged_in_user?, only: :create

  def create
    ActivationMailWorker.perform_async(current_user.id)
    respond_to { |format| format.js }
  end

  def edit
    if @user = User.find_by(email: params[:email])
      if @user.activated?
        flash[:info] = 'your account is already activated'
        login(@user)
      end
      if @user.is_digest?(:activation, params[:id])
        @user.activate_account
        flash[:success] = 'account activated'
        login(@user)
      end
    else
      flash[:danger] = 'invalid activation link'
    end
    redirect_to root_path
  end
end
