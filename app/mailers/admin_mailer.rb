class AdminMailer < ApplicationMailer
  def flag_notification(receiver, poll)
    @poll = poll
    mail to: receiver.email, subject: "poll #{@poll.id} flagged"
  end

  def contact_message(sender_email, receiver_email, message)
    @message = message
    mail from: sender_email, to: receiver_email, subject: 'Message from a user of Buck O Five'
  end

  class << self
    def send_flag_notification(poll)
      User.admins.find_each do |admin|
        flag_notification(admin, poll).deliver_now
      end
    end

    def send_contact_message(sender_email, message)
      User.admins.find_each do |admin|
        contact_message(sender_email, admin.email, message).deliver_now
      end
    end
  end
end
