module SessionsHelper
  def logged_in?
    !current_user.nil?
  end

  def current_user
    return @current_user if @current_user
    if session[:user_id] ||= cookies.signed[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    end
  end

  def login(user)
    session[:user_id] = user.id
  end

  def logout(user)
    forget(user)
    session.delete(:user_id)
    @current_user = nil
  end

  def remember(user)
    user.remember_me
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    user.forget_me
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # friendly forwarding
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def friendly_forward_or(default)
    redirect_to(session.delete(:forwarding_url) || default)
  end

  private
    def logged_in_user
      unless logged_in?
        store_location
        flash[:info] = 'please log in first'
        redirect_to login_path
      end
    end

    def correct_user
      @user = User.find_by(id: params[:id])
      redirect_to root_path unless @user && @user.id == session[:user_id]
    end
end
