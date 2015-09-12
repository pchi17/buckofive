class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      login(@user)
      remember(@user) if params[:user][:remember_me] == '1'
      @user.send_activation_email
      flash[:warning]   = 'please check your email to activate your account'
      redirect_to root_path
    else
      render :new
    end
  end

  def index
    if term = params[:search_term]
      users = User.where("LOWER(name) LIKE '%#{term.downcase}%'")
    else
      users = User.all
    end
    @users = users.paginate(page: params[:page], per_page: 10)
  end

  def edit
  end

  def update
    (@user.skip_password = true) unless params[:user][:password]
    if @user.update_attributes(user_params)
      flash[:success] = 'profile updated'
      redirect_back_or root_path
    else
      render :edit
    end
  end

  def destroy
    unless @user = User.find_by(id: params[:id])
      return redirect_back_or edit_user_path current_user
    end

    if @user.id == session[:user_id]
      @user.destroy
      flash[:info] = 'your account has been deleted :('
      redirect_to root_path
    elsif current_user.admin?
      @user.destroy
      redirect_back_or root_path
    else
      redirect_back_or root_path
    end
  end

  private
    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation
      )
    end
end
