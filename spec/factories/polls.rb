# == Schema Information
#
# Table name: polls
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  content     :string(250)      not null
#  total_votes :integer          default(0), not null
#  flags       :integer          default(0), not null
#  picture     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :poll do
    creator
    content "Is admin cool?"

    after(:build) do |poll|
      choices_attributes = []
      choices_attributes << attributes_for(:choice, :yes)
      choices_attributes << attributes_for(:choice, :no)
      poll.choices_attributes = choices_attributes
    end
  end
end
