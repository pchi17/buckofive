# == Schema Information
#
# Table name: polls
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  content     :string(250)      not null
#  total_votes :integer          default(0), not null
#  flags       :integer          default(0), not null
#  picture     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Poll, type: :model do
  let(:philip) { create(:philip, :with_account, :activated) }
  subject { build(:poll, creator: philip) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :creator }
    it { expect(subject).to have_many :choices }
    it { expect(subject).to have_many :votes }
    it { expect(subject).to accept_nested_attributes_for(:choices) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :creator }
    it { expect(subject).to validate_presence_of :content }
    it { expect(subject).to validate_length_of(:content).is_at_most(250) }
    it { expect(subject).to validate_uniqueness_of(:content).case_insensitive }
    it 'validates creator is activated' do
      mike = create(:mike, :with_account)
      expect(build(:poll, creator: mike)).to be_invalid
    end
  end

  describe 'before_validation' do
    it 'strips content' do
      subject.content = "\r\n  what? \r\n\t"
      subject.save
      expect(subject.content).to eq("what?")
    end
  end

  describe 'delete cascade' do
    it 'is deleted when user is deleted' do
      subject.save
      expect {
        philip.delete
      }.to change(Poll, :count).by(-1)
    end
  end
end
