# == Schema Information
#
# Table name: accounts
#
#  user_id           :integer          not null, primary key
#  password_digest   :string
#  remember_digest   :string
#  activation_digest :string
#  reset_digest      :string
#  activated_at      :datetime
#  reset_sent_at     :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :account do
    user
    password              'foobar'
    password_confirmation 'foobar'

    trait :activated do
      activated_at Time.now
    end
  end
end
