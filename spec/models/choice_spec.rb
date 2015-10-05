# == Schema Information
#
# Table name: choices
#
#  id          :integer          not null, primary key
#  poll_id     :integer          not null
#  value       :string(50)       not null
#  votes_count :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Choice, type: :model do
  let(:user) { create(:philip, :with_account, :activated) }
  let(:poll) { build(:poll, creator: user) }
  subject { poll.choices.first }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :poll }
    it { expect(subject).to have_many :votes }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :poll }
    it { expect(subject).to validate_presence_of :value }
    it { expect(subject).to validate_length_of(:value).is_at_most(50) }
    it { expect(subject).to validate_uniqueness_of(:value).case_insensitive.scoped_to(:poll_id) }
  end

  describe 'before_validation' do
    it 'strips value' do
      subject.value = "\r\n  Alpha \r\n\t"
      subject.save
      expect(subject.value).to eq('Alpha')
    end
  end

  describe 'delete cascade' do
    it 'is deleted when poll is deleted' do
      poll.save
      expect {
        poll.delete
      }.to change(Choice, :count).by(-2)
      # poll has choices 'yes' and 'no'
    end
  end
end
