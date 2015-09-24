class Poll < ActiveRecord::Base
  belongs_to :user,  inverse_of: :polls
  has_many :choices, inverse_of: :poll
  has_many :votes, through: :choices
  accepts_nested_attributes_for :choices, reject_if: lambda { |a| a[:value].blank? }

  MINIMUM_CHOICES = 2

  before_validation :strip_content, :check_choices

  validates :user,    presence: true
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
    choices.rank_by_votes.each do |c|
      if choice_ids.include?(c.id)
        c.selected_by_user = true
      else
        c.selected_by_user = false
      end
    end
  end

  def percentage(choice)
    ('%.2f' % ((choice.votes_count.to_f / total_votes) * 100)) + "%"
  end

  def created_by?(user)
    user_id == user.id
  end

  class << self
    def created_by(user)
      where(user: user)
    end

    def voted_by(user)
      joins(:votes).where("votes.user_id = ?", user.id)
    end

    def filter_by(user, filter)
      case filter
      when 'created_by_me'
        created_by(user)
      when 'voted_by_me'
        voted_by(user)
      else
        all
      end
    end

    def search(term, col, dir, page, per_page = 10)
      if term
        polls = where("LOWER(content) LIKE :term", term: "%#{term.downcase}%").order("#{col} #{dir}")
      else
        polls = order("#{col} #{dir}")
      end
      polls.paginate(page: page, per_page: per_page)
    end
  end

  private
    def strip_content
      content.strip! if content
    end

    def check_choices
      values = Hash.new(0)
      choices.each do |c|
        values[c.value.downcase] += 1
      end

      if values.count < MINIMUM_CHOICES
        errors.add(:choices, 'you must provide 2 unique choices')
      end

      dups = values.select { |k, v| v > 1 }.keys

      choices.each do |c|
        c.duplicate_choice = true if dups.include?(c.value.downcase)
      end
    end
end
