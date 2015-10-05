# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  poll_id    :integer          not null
#  message    :string(140)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :comment do
    user
    poll
    message 'this is a nice poll'
  end
end
