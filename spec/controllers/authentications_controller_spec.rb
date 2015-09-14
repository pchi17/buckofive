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
          @user = create(:user)
          @auth = create(:authentication, user: @user)
        end
        after(:all) { DatabaseCleaner.clean_with(:deletion) }

        it 'finds the correct @authentication' do
          expect(assigns(:authentication)).to eq(@auth)
        end

        it 'updates current_user name' do
          expect(current_user.name).to eq(auth_hash.info.nickname)
        end

        it 'updates current_user image_url' do
          expect(current_user.image_url).to eq(auth_hash.info.image)
        end

        it 'updates @authentication token' do
          expect(assigns(:authentication).token).to eq(auth_hash.credentials.token)
        end

        it 'updates @authentication secret' do
          expect(assigns(:authentication).secret).to eq(auth_hash.credentials.secret)
        end

        it 'activates current_user if not already activated' do
          expect(current_user.activated?).to be true
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to edit_profile_path }
        end
      end

      context 'when authentication does not exist in the database' do
        before(:all) { @user = create(:user) }
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
          expect(current_user.image_url).to eq(auth_hash.info.image)
        end

        it 'activates current_user if not already activated' do
          expect(current_user.activated?).to be true
        end

        context 'flash and redirect' do
          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to edit_profile_path }
        end
      end

    end

    context 'when not logged in' do
      before :each do |example|
        logout(current_user) if logged_in?
        session[:forwarding_url] = profile_path
        get :twitter unless example.metadata[:skip_before]
      end

      context 'when authentication already exists in the database' do
        before :all do
          @user = create(:user)
          @auth = create(:authentication, user: @user)
        end

        after(:all) { DatabaseCleaner.clean_with(:deletion) }

        it 'finds the correct @authentication' do
          expect(assigns(:authentication)).to eq(@auth)
        end

        it 'finds the associated @user' do
          expect(assigns(:user)).to eq(@user)
        end

        it 'updates current_user name' do
          expect(assigns(:user).name).to eq(auth_hash.info.nickname)
        end

        it 'updates current_user image_url' do
          expect(assigns(:user).image_url).to eq(auth_hash.info.image)
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
          it { expect(subject).to redirect_to profile_path }
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

        it 'creates a @user without password' do
          expect(assigns(:user).email).to be_nil
        end

        it 'creates a @user with name from auth_hash' do
          expect(assigns(:user).name).to eq(auth_hash.info.nickname)
        end

        it 'creates a @user with image_url from auth_hash' do
          expect(assigns(:user).image_url).to eq(auth_hash.info.image)
        end

        it 'creates a new @authentication associated with the @user', skip_before: true do
          expect(Authentication.count).to eq(0)
          get :twitter
          expect(assigns(:user).authentications.count).to eq(1)
        end

        it 'activates @user' do
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
          it { expect(subject).to redirect_to profile_path }
        end
      end
    end
  end

  describe '#failure' do
    before(:each) { get :failure }
    it { expect(subject).to set_flash[:danger] }
    it { expect(subject).to redirect_to root_path }
  end
end
