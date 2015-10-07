module ApplicationHelper
  def page_title(title = nil)
    base = 'Buck O Five'
    title.blank? ? base : "#{title} | #{base}"
  end

  def profile_picture(user, size = 50)
    unless source = user.image
      gravatar_id = Digest::MD5::hexdigest(user.email)
      source      = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    end
    klass = user.activated? ? nil : ' user-nonactivated'
    image_tag(source, alt: user.name, class: "portrait#{klass}" ,size: "#{size}")
  end

  def twitter_button(klass = 'btn-block', href = '/auth/twitter')
    link_to(href, class: "btn btn-twitter #{klass}") do
      content_tag(:span, 'Connect to Twitter') +
      image_tag('twitter.png', alt: 'Twitter Logo', size: '20')
    end
  end

  def render_error_message(obj)
    if obj.errors.any?
      render 'shared/error_messages', object: obj
    end
  end

  # sorting a table
  def table_sort(attribute, title = nil)
    title ||= attribute.titleize
    direction = (attribute == sort_column && sort_direction == 'asc')? 'desc' : 'asc'
    link_to title, params.merge(sort: attribute, direction: direction , page: nil), remote: true
  end

  private
    def sort_column
      Poll.column_names.include?(params[:sort]) ? params[:sort] : 'created_at'
    end

    def sort_direction
      ['asc', 'desc'].include?(params[:direction]) ? params[:direction] : 'desc'
    end
end
