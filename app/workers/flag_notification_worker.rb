class FlagNotificationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(poll_id)
    poll = Poll.find(poll_id)
    AdminMailer.send_flag_notification(poll)
  end
end
