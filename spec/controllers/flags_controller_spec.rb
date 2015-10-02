require 'rails_helper'

RSpec.describe FlagsController, type: :controller do
  before(:all) do
    @philip = create(:philip, :with_account, :activated)
    @poll   = create(:poll, creator: @philip)
  end

  before(:each) do |example|
    login(@philip)
    post :create, poll_id: @poll unless example.metadata[:skip_before]
  end
  it 'increments the flag counter', skip_before: true do
    expect {
      post :create, poll_id: @poll, format: :js
      @poll.reload
    }.to change { @poll.flags }.by(1)
  end

  it 'notifies all admins with email', skip_before: true do
    admin_count = User.admins.count
    expect {
      post :create, poll_id: @poll, format: :js
    }.to change { ActionMailer::Base.deliveries.size }.by(admin_count)
  end

  it { expect(subject).to set_flash[:info] }
  it { expect(subject).to redirect_to @poll }
end
