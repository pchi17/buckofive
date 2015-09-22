require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:philip) { create(:philip) }
  let(:mike)   { create(:mike) }
  let(:choice)  { create(:poll, user: philip).choices.first }
  subject { build(:vote, user: mike, choice: choice) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :user }
    it { expect(subject).to belong_to :choice }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :user }
    it { expect(subject).to validate_presence_of :choice }
    it 'validates each user can select one choice once' do
      subject.save
      expect(subject).to validate_uniqueness_of(:choice).scoped_to(:user_id)
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
      }.to change { Choice.first.votes_count }.by(-1)
    end
  end
end
