# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview
  def flag_notification
    recipient = User.find(1)
    poll      = Poll.find(1)
    AdminMailer.flag_notification(recipient, poll)
  end
end
