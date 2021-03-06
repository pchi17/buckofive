class UsersController < ApplicationController
  before_action :logged_in_user?, only: [:index, :destroy]
  before_action :admin_user?,     only: :index

  def new
    @user = User.new
    @user.build_account
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login(@user)
      remember(@user) if params[:user][:remember_me] == '1'
      ActivationMailWorker.perform_async(@user.id)
      flash[:warning] = 'please check your email to activate your account'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    @users = User.search(params[:search_term], params[:page])
  end

  def destroy
    @user = User.find(params[:id])
    if @user.id == session[:user_id]
      @user.destroy
      flash[:info] = 'your account has been deleted :('
      redirect_to root_path
    elsif current_user.admin?
      @user.destroy
      redirect_to users_path
    else
      flash[:info] = 'you cannot do that...'
      redirect_to root_path
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :name, :email, account_attributes: [
          :password,
          :password_confirmation
        ]
      )
    end
end
