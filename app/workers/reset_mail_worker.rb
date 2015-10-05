class ResetMailWorker
  include Sidekiq::Worker
  sidekiq_options queue: :high, retry: false

  def perform(user_id)
    user = User.find(user_id)
    user.send_reset_email
  end
end
