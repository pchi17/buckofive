require 'rails_helper'

RSpec.describe Poll, type: :model do
  let(:user) { create(:philip) }
  subject { build(:poll, user: user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :user }
    it { expect(subject).to have_many :choices }
    it { expect(subject).to have_many :votes }
    it { expect(subject).to accept_nested_attributes_for(:choices) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :content }
    it { expect(subject).to validate_length_of(:content).is_at_most(250) }
    it { expect(subject).to validate_uniqueness_of(:content).case_insensitive }
  end

  describe 'before_validation' do
    it 'strips content' do
      subject.content = "\r\n  what? \r\n\t"
      subject.save
      expect(subject.content).to eq("what?")
    end
  end

  describe '#creator' do
    it 'is an alias for #user' do
      expect(subject.creator).to eq(user)
    end
  end

  describe 'delete cascade' do
    it 'is deleted when user is deleted' do
      subject.save
      expect {
        user.delete
      }.to change(Poll, :count).by(-1)
    end
  end
end
