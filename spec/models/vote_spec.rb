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
# Indexes
#
#  index_votes_on_choice_id              (choice_id)
#  index_votes_on_user_id                (user_id)
#  index_votes_on_user_id_and_choice_id  (user_id,choice_id) UNIQUE
#

require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:philip) { create(:philip, :with_account, :activated) }
  let(:mike)   { create(:mike,   :with_account, :activated) }
  let(:choice) { create(:poll, user: philip).choices.first }
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
      expect(choice).to eq(Choice.first)
      expect {
        mike.destroy
      }.to change { Choice.first.votes_count }.by(-1)
    end
  end
end
