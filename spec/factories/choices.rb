# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  poll_id     :integer          not null
#  value       :string           not null
#  votes_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_choices_on_poll_id            (poll_id)
#  index_choices_on_poll_id_and_value  (poll_id,value) UNIQUE
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
