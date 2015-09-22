class Authentication < ActiveRecord::Base
  belongs_to :user, inverse_of: :authentications

  validates :user,     presence: true
  validates :provider, presence: true
  validates :uid,      presence: true, uniqueness: { scope: :provider }
end
