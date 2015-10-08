class AuthenticationsController < ApplicationController
  def twitter
    auth_hash = request.env['omniauth.auth'].except('extra')
    @user = User.find_or_create_with_omniauth(current_user, auth_hash)
    unless logged_in?
      login(@user)
      remember(@user)
    end
    flash[:success] = "connected to your #{auth_hash.provider} account"
    friendly_forward_or root_path
  end

  def failure
    flash[:danger] = 'authentication failed :('
    redirect_to root_path
  end
end
