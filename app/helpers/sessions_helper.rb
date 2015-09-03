module SessionsHelper
  def logged_in?
    !current_user.nil?
  end

  def login(user)
    session[:user_id] = user.id
  end

  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by(id: user_id)
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)
      if user.is_digest?(:remember, cookies[:remember_token])
        login(user)
        @current_user = user
      end
    end
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
    session.delete(:user_id)
  end

  # friendly forwarding
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def friendly_forward_or(default)
    redirect_to(session.delete(:forwarding_url) || default)
  end

  # redirect back
  def redirect_back_or(default)
    redirect_to (request.env['HTTP_REFERER'] || default)
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
      @user = User.find(params[:id])
      redirect_to root_path unless @user.id == session[:user_id]
    end
end
