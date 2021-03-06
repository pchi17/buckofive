require 'rails_helper'

RSpec.describe AuthenticationsController, type: :controller do
  describe 'GET #twitter' do
    before :all do
      mock_auth_hash
    end

    before :each do
      request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:twitter]
    end

    let(:auth_hash) { request.env['omniauth.auth'] }

    context 'when logged in' do
      before :each do |example|
        login(@user)
        get :twitter unless example.metadata[:skip_before]
      end

      context 'when authentication already exists in the database' do
        before :all do
          @user = create(:philip, :with_account)
          @auth = create(:authentication, user: @user)
        end
        after(:all) { DatabaseCleaner.clean_with(:deletion) }

        it 'updates current_user name' do
          expect(current_user.name).to eq(auth_hash.info.nickname)
        end

        it 'updates current_user image' do
          expect(current_user.image).to eq(auth_hash.info.image)
        end

        it 'activates current_user if not already activated' do
          expect(current_user.activated?).to be true
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to root_path }
        end
      end

      context 'when authentication does not exist in the database' do
        before(:all) { @user = create(:philip, :with_account) }
        after(:all)  { DatabaseCleaner.clean_with(:deletion) }

        it 'creates a new authentication associated with current_user', skip_before: true do
          expect {
            get :twitter
          }.to change(current_user.authentications, :count).by(1)
        end

        it 'updates current_user name' do
          expect(current_user.name).to eq(auth_hash.info.nickname)
        end

        it 'updates current_user image_url' do
          expect(current_user.image).to eq(auth_hash.info.image)
        end

        it 'activates current_user if not already activated' do
          expect(current_user.activated?).to be true
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to root_path }
        end
      end
    end

    context 'when not logged in' do
      before :each do |example|
        logout(current_user) if logged_in?
        session[:forwarding_url] = about_path
        get :twitter unless example.metadata[:skip_before]
      end

      context 'when authentication already exists in the database' do
        before :all do
          @user = create(:philip, :with_account)
          @auth = create(:authentication, user: @user)
        end

        after(:all) { DatabaseCleaner.clean_with(:deletion) }

        it 'finds the associated @user' do
          expect(assigns(:user)).to eq(@user)
        end

        it 'updates current_user name' do
          expect(assigns(:user).name).to eq(auth_hash.info.nickname)
        end

        it 'updates current_user image_url' do
          expect(assigns(:user).image).to eq(auth_hash.info.image)
        end

        it 'activates current_user if not already activated' do
          expect(assigns(:user).activated?).to be true
        end

        it 'logs in @user' do
          expect(session[:user_id]).to eq(assigns(:user).id)
        end

        it 'remembers @user' do
          expect(cookies.signed[:user_id]).to eq(assigns(:user).id)
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to about_path }
        end
      end

      context 'when authentication does not exist in the database' do
        it 'creates a new @user', skip_before: true  do
          expect {
            get :twitter
          }.to change(User, :count).by(1)
        end

        it 'creates a @user without email' do
          expect(assigns(:user).email).to be_nil
        end

        it 'builds an account for the user' do
          expect(assigns(:user).account).to_not be_nil
        end

        it 'creates a @user without password' do
          expect(assigns(:user).account.password).to be_nil
        end

        it 'creates a @user with name from auth_hash' do
          expect(assigns(:user).name).to eq(auth_hash.info.nickname)
        end

        it 'creates a @user with image_url from auth_hash' do
          expect(assigns(:user).image).to eq(auth_hash.info.image)
        end

        it 'creates a new @authentication associated with the @user', skip_before: true do
          expect(Authentication.count).to eq(0)
          get :twitter
          expect(assigns(:user).authentications.count).to eq(1)
        end

        it 'activates @user' do
          expect(assigns(:user).activated?).to be true
          expect(assigns(:user).account.activated_at).to_not be_nil
        end

        it 'logs in @user' do
          expect(session[:user_id]).to eq(assigns(:user).id)
        end

        it 'remembers @user' do
          expect(cookies.signed[:user_id]).to eq(assigns(:user).id)
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to about_path }
        end
      end
    end
  end

  describe 'GET #failure' do
    before(:each) { get :failure }
    it { expect(subject).to set_flash[:danger] }
    it { expect(subject).to redirect_to root_path }
  end
end
