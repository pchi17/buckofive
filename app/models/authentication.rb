# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string           not null
#  uid        :string           not null
#  token      :string
#  secret     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Authentication < ActiveRecord::Base
  belongs_to :user, inverse_of: :authentications

  validates :user,     presence: true
  validates :provider, presence: true
  validates :uid,      presence: true, uniqueness: { scope: :provider }
end
