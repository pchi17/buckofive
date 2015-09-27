class Choice < ActiveRecord::Base
  attr_accessor :duplicate_choice, :selected_by_user

  belongs_to :poll,  inverse_of: :choices
  has_many   :votes, inverse_of: :choice

  before_validation { value.strip! if value }

  validates :poll,  presence: true
  validates :value, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false, scope: :poll }
  validate  :is_duplicate?

  def self.rank_by_votes
    order('votes_count DESC')
  end

  def percentage
    ('%.2f' % ((votes_count.to_f / poll.total_votes) * 100)) + "%"
  end

  private
    def is_duplicate?
      if duplicate_choice
        errors.add(:value, 'choices must be unique (case insensitive)')
      end
    end
end
