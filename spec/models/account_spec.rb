# == Schema Information
#
# Table name: accounts
#
#  user_id           :integer          not null, primary key
#  password_digest   :string
#  remember_digest   :string
#  activation_digest :string
#  reset_digest      :string
#  activated_at      :datetime
#  reset_sent_at     :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:philip) { build(:philip, :with_account) }
  subject { philip.account }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to belong_to :user }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :user }
    it { expect(subject).to validate_presence_of :password }
    it { expect(subject).to validate_length_of(:password).is_at_least(6) }
    it { expect(subject).to validate_length_of(:password).is_at_most(32) }
    it { expect(subject).to validate_confirmation_of :password }
    it 'validates uniqueness of user' do
      philip.save
      expect(subject).to validate_uniqueness_of :user
    end
  end

  describe 'delete cascade' do
    it 'is handled by the database' do
      philip.save
      expect {
        philip.delete
      }.to change { Account.count }.by(-1)
    end
  end
end
