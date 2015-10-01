class Contact
  include ActiveModel::Model
  attr_accessor :sender_email, :message

  validates :sender_email, presence: true, format: { with: User::VALID_EMAIL_FORMAT }
  validates :message,      presence: true
end
