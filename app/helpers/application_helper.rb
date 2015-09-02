module ApplicationHelper
  def page_title(title = nil)
    base = 'Buck O Five'
    title.blank? ? base : "#{title} | #{base}" 
  end
end
