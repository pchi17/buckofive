class AuthenticationsController < ApplicationController
  def new
    auth_hash = request.env['omniauth.auth'].except('extra')
    if logged_in?
      if @authentication = current_user.authentications.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
        current_user.update_columns(
          name:      auth_hash.info.nickname,
          image_url: auth_hash.info.image
        )
        @authentication.update_columns(
          token:  auth_hash.credentials.token,
          secret: auth_hash.credentials.secret
        )
        current_user.activate_account unless current_user.activated?
        flash[:success] = "name and picture synced with your #{auth_hash.provider} account"
      else
        current_user.update_columns(
          name:      auth_hash.info.nickname,
          image_url: auth_hash.info.image
        )
        current_user.authentications.create(
          provider: auth_hash.provider,
          uid:      auth_hash.uid,
          token:    auth_hash.credentials.token,
          secret:   auth_hash.credentials.secret
        )
        current_user.activate_account unless current_user.activated?
        flash[:success] = "#{auth_hash.provider} account connected"
      end
      redirect_back_or root_path
    else
      if @authentication = Authentication.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
        @user = @authentication.user
        @user.update_columns(
          name:      auth_hash.info.nickname,
          image_url: auth_hash.info.image
        )
        @authentication.update_columns(
          token:  auth_hash.credentials.token,
          secret: auth_hash.credentials.secret
        )
        @user.activate_account unless @user.activated?
        login(@user)
      else
        @user = User.new(
          name:      auth_hash.info.nickname,
          image_url: auth_hash.info.image,
          activated:    true,
          activated_at: Time.now
        )
        @user.save(validate: false)
        @user.authentications.create(
          provider: auth_hash.provider,
          uid:      auth_hash.uid,
          token:    auth_hash.credentials.token,
          secret:   auth_hash.credentials.secret
        )
        login(@user)
      end
      flash[:success] = "signed in with your #{auth_hash.provider} account"
      redirect_to root_path
    end
  end

  def failure
    flash[:danger] = 'authentication failed :('
    redirect_back_or root_path
  end
end
