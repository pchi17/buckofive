class ContactMessageWorker
  include Sidekiq::Worker

  def perform(sender_email, message)
    contact = Contact.new(sender_email: sender_email, message: message)
    AdminMailer.send_contact_message(contact)
  end
end
