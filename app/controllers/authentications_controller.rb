class AuthenticationsController < ApplicationController
  def twitter
    auth_hash = request.env['omniauth.auth'].except('extra')
    if logged_in?
      if @authentication = current_user.authentications.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
        current_user.update_columns(
          name:  auth_hash.info.nickname,
          image: auth_hash.info.image
        )
        current_user.activate_account
        flash[:success] = "name and picture synced with your #{auth_hash.provider} account"
        @authentication.update_columns(
          token:  auth_hash.credentials.token,
          secret: auth_hash.credentials.secret
        )
      else
        current_user.update_columns(
          name:  auth_hash.info.nickname,
          image: auth_hash.info.image
        )
        current_user.activate_account
        flash[:success] = "#{auth_hash.provider} account connected"
        current_user.authentications.create(
          provider: auth_hash.provider,
          uid:      auth_hash.uid,
          token:    auth_hash.credentials.token,
          secret:   auth_hash.credentials.secret
        )
      end
      redirect_to profile_path
    else
      if @authentication = Authentication.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
        @user = @authentication.user
        @user.update_columns(
          name:  auth_hash.info.nickname,
          image: auth_hash.info.image
        )
        @authentication.update_columns(
          token:  auth_hash.credentials.token,
          secret: auth_hash.credentials.secret
        )
        @user.activate_account unless @user.activated?
        login(@user)
        remember(@user)
      else
        @user = User.new(
          name:      auth_hash.info.nickname,
          image: auth_hash.info.image,
          activated:    true
        )
        @user.build_account(activated_at: Time.now)
        @user.save(validate: false)
        @user.authentications.create(
          provider: auth_hash.provider,
          uid:      auth_hash.uid,
          token:    auth_hash.credentials.token,
          secret:   auth_hash.credentials.secret
        )
        login(@user)
        remember(@user)
      end
      flash[:success] = "signed in with your #{auth_hash.provider} account"
      friendly_forward_or profile_path
    end
  end

  def failure
    flash[:danger] = 'authentication failed :('
    redirect_to root_path
  end
end
