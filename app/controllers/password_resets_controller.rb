class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user?,      only: [:edit, :update]
  before_action :is_link_expired?, only: [:edit, :update]

  def new
  end

  def create
    if @user = User.find_by(email: params[:password_reset][:email])
      ResetMailWorker.perform_async(@user.id)
      flash[:info] = 'please check your email for a password reset message'
      redirect_to login_path
    else
      flash[:danger] = 'Email is not registered'
      render :new
    end
  end

  def edit
  end

  def update
    if params[:account][:password].blank?
      flash.now[:danger] = 'password cannot be blank'
      render :edit
    else
      if @user.account.update_attributes(password_params)
        @user.clear_reset_digest
        login(@user)
        flash[:success] = 'password reset successful'
        redirect_to root_path
      else
        render :edit
      end
    end
  end

  private
    def password_params
      params.require(:account).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user?
      unless @user && @user.is_digest?(:reset, params[:id])
        flash[:danger] = 'invalid password reset link'
        redirect_to login_path
      end
    end

    def is_link_expired?
      if @user.is_reset_expired?
        flash[:warning] = 'password reset link is expired'
        redirect_to new_password_reset_path
      end
    end
end
