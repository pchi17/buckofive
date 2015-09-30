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

class Poll < ActiveRecord::Base
  belongs_to :user,  inverse_of: :polls
  has_many :choices, inverse_of: :poll
  has_many :votes, through: :choices
  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: lambda { |a| a[:value].blank? }

  mount_uploader :picture, PollPhotoUploader

  MINIMUM_CHOICES = 2

  before_validation :strip_content, :check_choices

  validates :user,    presence: true
  validates :content, presence: true, length: { maximum: 250 }, uniqueness: { case_sensitive: false }
  validate  :user_activated
  validate  :picture_size

  alias creator user

  def get_choice_ids(user)
    votes.where(user: user).pluck(:choice_id)
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

  def voted_by?(user)
    get_choice_ids(user).present?
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

  def picture_size_mb
    (picture.size.to_f/1024/1024).round(2)
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
        errors.add(:choices, "you must provide #{MINIMUM_CHOICES} unique choices")
      end

      dups = values.select { |k, v| v > 1 }.keys

      choices.each do |c|
        c.duplicate_choice = true if dups.include?(c.value.downcase)
      end
    end

    def picture_size
      if picture.size > 3.megabytes
        errors.add(:picture, "must be less than 3MB, current size is #{picture_size_mb}MB")
      end
    end

    def user_activated
      unless creator && creator.activated?
        errors.add(:user, 'must be activated')
      end
    end
end
