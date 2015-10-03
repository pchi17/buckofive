class AdminMailer < ApplicationMailer
  def flag_notification(receiver, poll)
    @poll = poll
    mail to: receiver.email, subject: "poll #{@poll.id} flagged"
  end

  def contact_message(receiver, contact)
    @message = contact.message
    mail from: contact.sender_email, to: receiver.email, subject: 'Message from a user of Buck O Five'
  end

  class << self
    def send_flag_notification(poll)
      User.admins.find_each do |admin|
        flag_notification(admin, poll).deliver_now
      end
    end

    def send_contact_message(contact)
      User.admins.find_each do |admin|
        contact_message(admin, contact).deliver_now
      end
    end
  end
end
