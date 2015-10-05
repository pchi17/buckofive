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

class Vote < ActiveRecord::Base
  belongs_to :voter,  inverse_of: :votes, class_name: 'User', foreign_key: 'user_id'
  belongs_to :choice, inverse_of: :votes, counter_cache: :votes_count

  after_create  { Poll.increment_counter(:total_votes, self.choice.poll.id) }
  after_destroy { Poll.decrement_counter(:total_votes, self.choice.poll.id) }

  validates :voter,  presence: true
  validates :choice, presence: true, uniqueness: { scope: :voter }
  validate  :voter_activated

  private
    def voter_activated
      unless voter && voter.activated?
        errors.add(:voter, 'must be activated')
      end
    end
end
