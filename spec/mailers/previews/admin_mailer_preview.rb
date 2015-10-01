# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def flag_notification
    recipient = User.find(1)
    poll      = Poll.find(1)
    AdminMailer.flag_notification(recipient, poll)
  end

  def contact_message
    sender_email   = User.find(2).email
    receiver_email = User.find(1).email
    message  = 'How are you doing?'
    AdminMailer.contact_message(sender_email, receiver_email, message)
  end
end
