class SessionsController < ApplicationController
  def new
  end

  def create
    if @user = User.find_by(email: params[:session][:email])
      if @user.authenticate(params[:session][:password])
        login(@user)
        remember(@user) if params[:session][:remember_me] == '1'
        friendly_forward_or(root_path)
      else
        flash.now[:danger] = 'password is incorrect'
        render :new
      end
    else
      flash.now[:danger] = 'Email is not registered'
      render :new
    end
  end

  def destroy
    logout(current_user) if logged_in?
    redirect_to root_path
  end
end
