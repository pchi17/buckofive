class Account < ActiveRecord::Base
  self.primary_key = 'user_id'
  attr_accessor :password, :password_confirmation
  belongs_to :user, inverse_of: :account

  validates :user,     presence: true, uniqueness: true
  validates :password, presence: true, length: (6..32), confirmation: true

  # since I did not use has_secure_password
  # I need to redefine password=
  def password=(str)
    @password = str
    self.password_digest = User.digest(str)
  end
end
