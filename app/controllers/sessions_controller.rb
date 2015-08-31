class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user
      if @user.authenticate(params[:session][:password])
        login(@user)
        redirect_to root_path
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
    session.delete(:user_id)
    redirect_to root_path
  end
end
