module SessionsHelper
  def logged_in?
    !session[:user_id].nil?
  end

  def login(user)
    session[:user_id] = user.id
  end

  def current_user
    @user ||= User.find_by(id: session[:user_id])
  end

  def logged_in_and_activated?
    return current_user.activated? if current_user
    return false
  end
end
