class Vote < ActiveRecord::Base
  belongs_to :user,   inverse_of: :votes
  belongs_to :choice, inverse_of: :votes, counter_cache: :votes_count

  after_create  { Poll.increment_counter(:total_votes, self.choice.poll.id) }
  after_destroy { Poll.decrement_counter(:total_votes, self.choice.poll.id) }

  validates :user,   presence: true
  validates :choice, presence: true, uniqueness: { scope: :user }
end
