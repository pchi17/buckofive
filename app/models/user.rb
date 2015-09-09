class User < ActiveRecord::Base
  has_many :authentications, dependent: :delete_all
  attr_accessor :remember_token, :activation_token, :reset_token
  
  before_save { email.downcase! if email }

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

  # login, logout
  def remember_me
    self.remember_token = User.new_token
    update_columns(remember_digest: User.digest(remember_token))
  end

  def forget_me
    update_columns(remember_digest: nil)
  end

  # account activation
  def create_activation_digest
    self.activation_token = User.new_token
    update_columns(activation_digest: User.digest(activation_token))
  end

  def send_activation_email
    create_activation_digest
    UserMailer.account_activation(self).deliver_now
  end

  def activate_account
    update_columns(activated: true, activated_at: Time.now)
  end

  # password reset
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest:  User.digest(reset_token),
      reset_sent_at: Time.now
    )
  end

  def clear_reset_digest
    update_columns(reset_digest: nil, reset_sent_at: nil)
  end

  def send_reset_email
    create_reset_digest
    UserMailer.password_reset(self).deliver_now
  end

  def is_reset_expired?
    # password reset links expire in 2 hours
    reset_sent_at < 2.hours.ago
  end

  def is_digest?(attribute, token)
    if digest = send("#{attribute}_digest")
      BCrypt::Password.new(digest).is_password?(token)
    else
      return false
    end
  end

  def has_authentication(provider)
    authentications.where(provider: provider).count > 0
  end
end
