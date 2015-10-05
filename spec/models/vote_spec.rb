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

require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:philip) { create(:philip, :with_account, :activated) }
  let(:mike)   { create(:mike,   :with_account, :activated) }
  let(:choice) { create(:poll, creator: philip).choices.first }
  subject { build(:vote, voter: mike, choice: choice) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :voter }
    it { expect(subject).to belong_to :choice }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :voter }
    it { expect(subject).to validate_presence_of :choice }
    it 'validates each user can select one choice once' do
      subject.save
      expect(subject).to validate_uniqueness_of(:choice).scoped_to(:user_id)
    end
    it 'validates voter is activated' do
      stephens = create(:stephens, :with_account)
      expect(build(:vote, voter: stephens, choice: choice)).to be_invalid
    end
  end

  describe 'delete cascade' do
    it 'is deleted when user is destroyed' do
      subject.save
      expect {
        mike.destroy
      }.to change { Vote.count }.by(-1)
    end

    it 'updates counter cache' do
      subject.save
      expect {
        mike.destroy
        choice.reload
      }.to change { choice.votes_count }.by(-1)
    end
  end
end
