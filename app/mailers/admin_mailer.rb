class AdminMailer < ApplicationMailer
  def flag_notification(recipient, poll)
    @poll = poll
    mail to: recipient.email, subject: "poll #{@poll.id} flagged"
  end

  class << self
    def send_flag_notification(poll)
      User.admins.find_each do |admin|
        flag_notification(admin, poll).deliver_now
      end
    end
  end
end
