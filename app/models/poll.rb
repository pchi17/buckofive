class Poll < ActiveRecord::Base
  belongs_to :user,  inverse_of: :polls
  has_many :choices, inverse_of: :poll
  has_many :votes, through: :choices
  accepts_nested_attributes_for :choices, reject_if: lambda { |a| a[:value].blank? }

  MINIMUM_CHOICES = 2

  before_validation do
    content.strip! if content

    values = Hash.new(0)
    choices.each do |c|
      values[c.value.downcase] += 1
    end

    if values.count < MINIMUM_CHOICES
      errors.add(:choices, 'you must provide 2 unique choices')
    end

    dups = values.select { |k, v| v > 1 }.keys

    choices.each do |c|
      c.duplicate_choice = true if dups.include?(c.value)
    end
  end

  validates :user,     presence: true
  validates :content, presence: true, length: { maximum: 250 }, uniqueness: { case_sensitive: false }

  alias creator user

  def get_choice_ids(user)
    @vote_ids ||= {}
    return @vote_ids[user] if @vote_ids[user]
    @vote_ids[user] = votes.where(user: user).pluck(:choice_id)
  end

  def voted_by?(user)
    get_choice_ids(user).present?
  end

  def get_choices(user)
    choice_ids   = get_choice_ids(user)
    choices.each do |c|
      if choice_ids.include?(c.id)
        c.selected_by_user = true
      else
        c.selected_by_user = false
      end
    end
    choices.sort do |a, b|
      compare = (b.votes_count <=> a.votes_count)
      compare.zero? ? (a.value <=> b.value) : compare
    end
  end

  def total_votes
    @total_votes ||= choices.inject(0) { |sum, choice| sum += choice.votes_count }
  end

  def percentage(choice)
    ('%.2f' % ((choice.votes_count.to_f / total_votes) * 100)) + "%"
  end
end
