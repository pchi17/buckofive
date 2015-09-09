require 'rails_helper'

RSpec.describe Authentication, type: :model do
  subject { build(:authentication) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to belong_to :user }
  it { expect(subject).to validate_presence_of :provider }
  it { expect(subject).to validate_presence_of :uid }
  it { expect(subject).to validate_uniqueness_of(:uid).scoped_to(:provider) }

  it 'saves provider in all lower case letters' do
    auth = build(:authentication, provider: 'Twitter')
    auth.save
    expect(auth.reload.provider).to eq('twitter')
  end
end
