require 'rails_helper'

RSpec.describe FlagsController, type: :controller do
  before(:all) do
    @philip = create(:philip, :with_account, :admin)
    @mike   = create(:mike,   :with_account, :activated)
    @poll1   = create(:poll, creator: @philip, content: 'poll1', flags: 5)
    @poll2   = create(:poll, creator: @philip, content: 'poll2', flags: 7)
    @poll3   = create(:poll, creator: @philip, content: 'poll3', flags: 0)
  end

  it { expect(subject).to use_before_action(:logged_in_user?) }
  it { expect(subject).to use_before_action(:activated_current_user?) }
  it { expect(subject).to use_before_action(:admin_user?) }

  describe 'POST #create' do
    before(:each) do |example|
      login(@mike)
      post :create, poll_id: @poll3 unless example.metadata[:skip_before]
    end
    it 'increments the flag counter', skip_before: true do
      expect {
        post :create, poll_id: @poll3, format: :js
        @poll3.reload
      }.to change { @poll3.flags }.by(1)
    end

    it 'notifies all admins with email', skip_before: true do
      admin_count = User.admins.count
      expect {
        post :create, poll_id: @poll3, format: :js
      }.to change { ActionMailer::Base.deliveries.size }.by(admin_count)
    end

    it { expect(subject).to set_flash[:info] }
    it { expect(subject).to redirect_to @poll3 }
  end

  describe 'GET #index' do
    context 'when logged in as admin' do
      before(:each) { login(@philip); get :index }
      it 'finds flagged polls and sorts them in desc order by flags' do
        expect(assigns(:polls)).to eq([@poll2, @poll1])
      end
      it { expect(subject).to render_template :index }
    end

    context 'when logged in as non admin' do
      it 'redirects to profile_path' do
        login(@mike)
        get :index
        expect(subject).to redirect_to profile_path
      end
    end
  end
end
