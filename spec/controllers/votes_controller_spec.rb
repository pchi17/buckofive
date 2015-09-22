require 'rails_helper'

RSpec.describe VotesController, type: :controller do
  let(:philip) { create(:philip, :activated) }
  let(:mike)   { create(:mike) }
  let(:poll)   { create(:poll, user: philip) }
  let(:choice) { poll.choices.first }

  it { expect(subject).to use_before_action(:logged_in_user?) }
  it { expect(subject).to use_before_action(:activated_current_user?) }

  describe 'POST #create' do
    context 'when not logged_in_user' do
      before(:each) do
        post :create, vote: { choice_id: choice.id }
      end

      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when current_user is not activated' do
      before(:each) do
        login(mike)
        post :create, vote: { choice_id: choice.id }
      end

      it { expect(subject).to set_flash[:warning] }
      it { expect(subject).to redirect_to edit_profile_path }
    end

    context 'with format.html' do
      it 'creates a vote' do
        login(philip)
        expect {
          post :create, vote: { choice_id: choice.id }
        }.to change { Vote.count }.by(1)
      end
    end

    context 'with format.js' do
      it 'creates a vote' do
        login(philip)
        expect {
          xhr :post, :create, vote: { choice_id: choice.id }
        }.to change { Vote.count }.by(1)
      end
    end

    context 'with invalid choice' do
      it 'does not create a vote' do
        login(philip)
        poll
        bad_choice = Choice.maximum(:id) + 1
        expect {
          post :create, vote: { choice_id: bad_choice }
        }.to_not change { Vote.count }
      end
    end

    context 'with duplicate vote' do
      it 'does not create a vote' do
        login(philip)
        create(:vote, user: philip, choice: choice)
        expect {
          post :create, vote: { choice_id: choice.id }
        }.to_not change { Vote.count }
      end
    end
  end
end
