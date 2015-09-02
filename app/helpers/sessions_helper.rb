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
      if user.is_remember_digest?(cookies[:remember_token])
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
end
