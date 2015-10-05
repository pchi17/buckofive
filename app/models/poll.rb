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
  belongs_to :creator, inverse_of: :polls, class_name: 'User', foreign_key: 'user_id'
  has_many :choices,  inverse_of: :poll
  has_many :comments, inverse_of: :poll
  has_many :votes, through: :choices
  accepts_nested_attributes_for :choices, allow_destroy: true, reject_if: lambda { |a| a[:value].blank? }

  mount_uploader :picture, PollPhotoUploader

  MINIMUM_CHOICES = 2

  before_validation :strip_content, :check_choices

  validates :creator, presence: true
  validates :content, presence: true, length: { maximum: 250 }, uniqueness: { case_sensitive: false }
  validate  :creator_activated
  validate  :picture_size

  def get_choices(user)
    choice_ids = votes.where(voter: user).pluck(:choice_id)
    choices.rank_by_votes.each do |c|
      if choice_ids.include?(c.id)
        c.selected_by_user = true
      else
        c.selected_by_user = false
      end
    end
  end

  def voted_by?(user)
    votes.where(voter: user).count > 0
  end

  def created_by?(user)
    user_id == user.id
  end

  def flag
    increment!(:flags)
  end

  class << self
    def created_by(user)
      where(creator: user)
    end

    def voted_by(user)
      distinct.joins(:votes).where("votes.user_id = ?", user.id)
    end

    def not_voted_by(user)
      voted_polls = user.choices.group(:poll_id).pluck(:poll_id)
      voted_polls.empty? ? all : where("id NOT IN (?)", voted_polls)
    end

    def commented_by(user)
      distinct.joins(:comments).where("comments.user_id = ?", user.id)
    end

    def filter_by(user, filter)
      case filter
      when 'created'
        created_by(user)
      when 'voted'
        voted_by(user)
      when 'commented'
        commented_by(user)
      when 'fresh'
        not_voted_by(user)
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

    def flagged
      Poll.where("flags > 0").order(flags: :desc)
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

    def creator_activated
      unless creator && creator.activated?
        errors.add(:creator, 'must be activated')
      end
    end
end
