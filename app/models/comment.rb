class Comment < ActiveRecord::Base
  belongs_to :user, inverse_of: :comments
  belongs_to :poll, inverse_of: :comments

  default_scope lambda { order(created_at: :desc) }

  before_validation { content.strip! if content }

  validates :user,    presence: true
  validates :poll,    presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validate  :user_activated

  def created_by?(user)
    user_id == user.id
  end

  private
    def user_activated
      unless user && user.activated?
        errors.add(:user, 'must be activated')
      end
    end
end
