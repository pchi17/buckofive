# == Schema Information
#
# Table name: polls
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  content     :string           not null
#  total_votes :integer          default(0), not null
#  picture     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_polls_on_content  (content) UNIQUE
#  index_polls_on_user_id  (user_id)
#

FactoryGirl.define do
  factory :poll do
    user
    content "Is admin cool?"

    after(:build) do |poll|
      choices_attributes = []
      choices_attributes << attributes_for(:choice, :yes)
      choices_attributes << attributes_for(:choice, :no)
      poll.choices_attributes = choices_attributes
    end
  end
end
