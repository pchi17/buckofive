module ApplicationHelper
  def page_title(title = nil)
    base = 'Buck O Five'
    title ? "#{title} | #{base}" : base
  end
end
