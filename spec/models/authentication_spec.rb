# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  provider   :string           not null
#  uid        :string           not null
#  token      :string
#  secret     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Authentication, type: :model do
  let(:user) { create(:philip, :with_account) }
  subject { build(:authentication, user: user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to belong_to :user }
  it { expect(subject).to validate_presence_of :user }
  it { expect(subject).to validate_presence_of :provider }
  it { expect(subject).to validate_presence_of :uid }
  it { expect(subject).to validate_uniqueness_of(:uid).scoped_to(:provider) }

  it 'is deleted when use is deleted' do
    subject.save
    expect {
      user.delete
    }.to change(Authentication, :count).by(-1)
  end
end
