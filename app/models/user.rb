# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  email      :string
#  image      :string
#  admin      :boolean          default(FALSE)
#  activated  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessor :remember_token, :activation_token, :reset_token
  has_one  :account,         inverse_of: :user
  has_many :authentications, inverse_of: :user
  has_many :polls,           inverse_of: :creator
  has_many :comments,        inverse_of: :user
  has_many :votes,           inverse_of: :voter, dependent: :destroy
  has_many :choices, through: :votes


  accepts_nested_attributes_for :account

  default_scope lambda { order(name: :asc) }

  before_save { email.downcase! if email }

  VALID_EMAIL_FORMAT = /\A[\w\+\-\.]+@[a-z\d\-\.]+[a-z\d\-]\.[a-z]+\z/i

  validates :name,  presence: true
  validates :email, presence: true, format: { with: VALID_EMAIL_FORMAT }, uniqueness: { case_sensitive: false }
  validate  :has_account

  # instance methods

  # authenticate digests
  def authenticate(password)
    is_digest?(:password, password) ? self : false
  end

  def is_digest?(attribute, token)
    if digest = account.send("#{attribute}_digest")
      BCrypt::Password.new(digest).is_password?(token)
    else
      return false
    end
  end

  # login, logout
  def remember_me
    self.remember_token = User.new_token
    account.update_columns(remember_digest: User.digest(remember_token))
  end

  def forget_me
    account.update_columns(remember_digest: nil)
  end

  # account activation
  def create_activation_digest
    self.activation_token = User.new_token
    account.update_columns(activation_digest: User.digest(activation_token))
  end

  def send_activation_email
    create_activation_digest
    UserMailer.account_activation(self).deliver_now
  end

  def activate_account
    unless activated?
      update_columns(activated: true)
      account.update_columns(activated_at: Time.now)
    end
  end

  # password reset
  def create_reset_digest
    self.reset_token = User.new_token
    account.update_columns(
      reset_digest:  User.digest(reset_token),
      reset_sent_at: Time.now
    )
  end

  def clear_reset_digest
    account.update_columns(reset_digest: nil, reset_sent_at: nil)
  end

  def send_reset_email
    create_reset_digest
    UserMailer.password_reset(self).deliver_now
  end

  def is_reset_expired?
    # password reset links expire in 2 hours
    if time_sent = account.reset_sent_at
      time_sent < 2.hours.ago
    else
      true # if it is nil, assume it is expired therefore invalid.
    end
  end

  # class methods
  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest(token)
      if ActiveModel::SecurePassword.min_cost
        cost = BCrypt::Engine::MIN_COST
      else
        cost = BCrypt::Engine.cost
      end
      BCrypt::Password.create(token, cost: cost)
    end

    def search(term, page, per_page = 10)
      users = term ? User.where("LOWER(name) LIKE :term", term: "%#{term.downcase}%") : User.all
      users.paginate(page: page, per_page: per_page)
    end

    def admins
      where("admin AND email IS NOT NULL")
    end

    def find_or_create_with_omniauth(user, auth_hash)
      if user
        user.update_columns(name:  auth_hash.info.nickname, image: auth_hash.info.image)
        user.activate_account
        if auth = user.authentications.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
          auth.update_columns(token: auth_hash.credentials.token, secret: auth_hash.credentials.secret)
        else
          user.authentications.create(
            provider: auth_hash.provider,
            uid:      auth_hash.uid,
            token:    auth_hash.credentials.token,
            secret:   auth_hash.credentials.secret
          )
        end
      else
        if auth = Authentication.find_by(provider: auth_hash.provider, uid: auth_hash.uid)
          user = auth.user
          user.activate_account
          user.update_columns(name:  auth_hash.info.nickname,     image: auth_hash.info.image)
          auth.update_columns(token: auth_hash.credentials.token, secret: auth_hash.credentials.secret)
        else
          user = new(name: auth_hash.info.nickname, image: auth_hash.info.image, activated: true)
          user.build_account(activated_at: Time.now)
          user.save(validate: false)
          user.authentications.create(
            provider: auth_hash.provider,
            uid:      auth_hash.uid,
            token:    auth_hash.credentials.token,
            secret:   auth_hash.credentials.secret
          )
        end
      end
      return user
    end
  end

  private
    def has_account
      if account.nil?
        errors.add(:account, ': user must have an account')
      end
    end
end
