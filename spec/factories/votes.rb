# == Schema Information
#
# Table name: votes
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  choice_id  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_votes_on_choice_id              (choice_id)
#  index_votes_on_user_id                (user_id)
#  index_votes_on_user_id_and_choice_id  (user_id,choice_id) UNIQUE
#

FactoryGirl.define do
  factory :vote do
    user
    choice
  end
end
