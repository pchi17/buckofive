# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  poll_id     :integer          not null
#  value       :string(50)       not null
#  votes_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :choice do
    poll

    trait :yes do
      value 'yes'
    end

    trait :no do
      value 'no'
    end
  end
end
