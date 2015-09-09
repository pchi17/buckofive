class Authentication < ActiveRecord::Base
  belongs_to :user

  before_save { provider.downcase! }
  
  validates :provider, presence: true
  validates :uid,      presence: true, uniqueness: { scope: :provider }
end
