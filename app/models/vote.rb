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

class Vote < ActiveRecord::Base
  belongs_to :user,   inverse_of: :votes
  belongs_to :choice, inverse_of: :votes, counter_cache: :votes_count

  after_create  { Poll.increment_counter(:total_votes, self.choice.poll.id) }
  after_destroy { Poll.decrement_counter(:total_votes, self.choice.poll.id) }

  validates :user,   presence: true
  validates :choice, presence: true, uniqueness: { scope: :user }
  validate  :user_activated

  private
    def user_activated
      unless user && user.activated?
        errors.add(:user, 'must be activated')
      end
    end
end
