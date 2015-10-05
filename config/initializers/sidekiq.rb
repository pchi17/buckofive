if Rails.env.production?
  Sidekiq.configure_server do |config|
    config.redis = { url: URI.parse(ENV['REDIS_PROVIDER']) }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: URI.parse(ENV['REDIS_PROVIDER']) }
  end
end
