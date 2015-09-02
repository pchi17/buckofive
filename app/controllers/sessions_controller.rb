class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user
      if @user.authenticate(params[:session][:password])
        login(@user)
        remember(@user) if params[:session][:remember_me] == '1'
        redirect_back_or(root_path)
      else
        flash.now[:danger] = 'Password is incorrect'
        render :new
      end
    else
      flash.now[:danger] = 'Email is not registered'
      render :new
    end
  end

  def destroy
    forget(current_user) if logged_in?
    redirect_to root_path
  end
end
