require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:philip) { create(:philip, :with_account, :activated) }
  let(:mike)   { create(:mike,   :with_account) } # not activated
  let(:poll)   { create(:poll, creator: philip) }
  subject { build(:comment, user: philip, poll: poll) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to validate_presence_of :user }
  it { expect(subject).to validate_presence_of :poll }
  it { expect(subject).to validate_presence_of :message }
  it { expect(subject).to validate_length_of(:message).is_at_most(140) }
  it 'validates user is activated' do
    expect(build(:comment, user: mike, poll: poll)).to be_invalid
  end

  describe 'before_validation' do
    it 'strips message' do
      subject.message = "   spaces!  \r\n"
      subject.save
      expect(subject.message).to eq('spaces!')
    end
  end

  describe '#created_by?' do
    context 'with correct user' do
      it 'returns true' do
        expect(poll.created_by?(philip)).to be true
      end
    end
    context 'with incorrect user' do
      it 'returns false' do
        expect(poll.created_by?(mike)).to be false
      end
    end
  end
end
