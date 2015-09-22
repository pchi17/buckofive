module ApplicationHelper
  def page_title(title = nil)
    base = 'Buck O Five'
    title.blank? ? base : "#{title} | #{base}"
  end

  def profile_picture(user, size = 80)
    unless source = user.image_url
      gravatar_id = Digest::MD5::hexdigest(user.email)
      source      = "https://secure.gravatar.com/avatar/#{gravatar_id}?#{size}"
    end
    klass = user.activated? ? nil : ' user-nonactivated'
    image_tag(source, alt: user.name, class: "portrait#{klass}" ,size: "#{size}")
  end
end
