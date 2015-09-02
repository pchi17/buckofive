class AccountActivationsController < ApplicationController
  def edit
    @user = User.find_by(email: params[:email])
    if @user && !@user.activated && @user.is_digest?(:activation, params[:id])
      @user.activate_account
      flash[:success] = 'account activated'
    else
      flash[:danger] = 'invalid activation link'
    end
    redirect_to root_path
  end
end
