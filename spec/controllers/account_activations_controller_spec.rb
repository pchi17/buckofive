require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  before(:all) { @philip = create(:philip, :with_account) }

  it { expect(subject).to use_before_action(:logged_in_user?) }

  describe 'POST #create' do
    context 'when not logged in' do
      before(:each) { |example| post :create, format: :js unless example.metadata[:skip_before] }

      it 'does not send an activation email', skip_before: true do
        expect {
          post :create, format: :js
        }.to_not change(ActionMailer::Base.deliveries, :size)
      end
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when logged in' do
      before(:each) do |example|
        login(@philip)
        post :create, format: :js unless example.metadata[:skip_before]
      end

      it 'sends an activation email', skip_before: true do
        expect {
          post :create, format: :js
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it { expect(response.content_type).to eq(Mime::JS) }
    end
  end

  describe 'GET #edit' do
    before(:all) { @philip.create_activation_digest }
    it 'checks that philip is not activated' do
      expect(@philip.activated?).to be false
    end

    context 'with valid activation_token and email' do
      context 'when the user is already activated' do
        before(:all) do
          @mike = create(:mike, :with_account, :activated)
          @mike.create_activation_digest
        end

        before(:each) do
          get :edit, id: @mike.activation_token, email: @mike.email
        end

        it 'finds the correct mike' do
          expect(assigns(:user)).to eq(@mike)
        end

        it 'logs in the user' do
          expect(session[:user_id]).to eq(@mike.id)
        end
        it { expect(subject).to set_flash[:info] }
        it { expect(subject).to redirect_to root_path }
      end

      context 'when the user is not activated' do
        before(:each) { get :edit, id: @philip.activation_token, email: @philip.email }

        it 'finds the correct philip' do
          expect(assigns(:user)).to eq(@philip)
        end

        it 'activates the user' do
          expect(assigns(:user).reload.activated?).to be true
        end

        it 'logs in the user' do
          expect(session[:user_id]).to eq(@philip.id)
        end
        it { expect(subject).to set_flash[:success] }
        it { expect(subject).to redirect_to root_path }
      end
    end

    context 'with invalid activation_token' do
      before(:each) { get :edit, id: @philip.activation_token + 'xxx', email: @philip.email }

      it 'does not activate the user' do
        expect(assigns(:user).reload.activated?).to be false
      end

      it { expect(subject).to redirect_to root_path }
    end

    context 'with invalid email' do
      before(:each) { get :edit, id: @philip.activation_token, email: @philip.email + 'xxx' }

      it 'returns nil for philip' do
        expect(assigns(:user)).to be_nil
      end

      it 'redirect_to root_path' do
        expect(subject).to redirect_to root_path
      end
    end
  end
end
