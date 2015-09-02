class User < ActiveRecord::Base
  attr_accessor :remember_token

  before_save { email.downcase! }

  VALID_EMAIL_FORMAT = /\A[\w\+\-\.]+@[a-z\d\-\.]+[a-z\d\-]\.[a-z]+\z/i

  validates :name,  presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_FORMAT }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  has_secure_password

  # class methods
  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest(password)
      if ActiveModel::SecurePassword.min_cost
        cost = BCrypt::Engine::MIN_COST
      else
        cost = BCrypt::Engine.cost
      end
      BCrypt::Password.create(password, cost: cost)
    end
  end

  # instance methods
  def remember_me
    self.remember_token = User.new_token
    update_columns(remember_digest: User.digest(remember_token))
  end

  def forget_me
    update_columns(remember_digest: nil)
  end

  def is_remember_digest?(token)
    BCrypt::Password.new(remember_digest).is_password?(token)
  end
end
