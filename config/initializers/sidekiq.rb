if Rails.env.production?
  require 'sidekiq'

  Sidekiq.configure_server do |config|
    config.redis = { url: ENV['REDISTOGO_URL'] }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: ENV['REDISTOGO_URL'] }
  end
end
