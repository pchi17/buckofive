class Vote < ActiveRecord::Base
  belongs_to :user,   inverse_of: :votes
  belongs_to :choice, inverse_of: :votes, counter_cache: :votes_count

  validates :user,   presence: true
  validates :choice, presence: true, uniqueness: { scope: :user }
end
