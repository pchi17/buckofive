module UsersHelper
  def profile_picture(user, size = 80)
    unless source = user.image_url
      gravatar_id = Digest::MD5::hexdigest(user.email)
      source      = "https://secure.gravatar.com/avatar/#{gravatar_id}?#{size}"
    end
    klass = user.activated? ? 'user-activated' : 'user-nonactivated'
    image_tag(source, alt: user.name, class: "profile-picture #{klass}", size: "#{size}")
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
