require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  def self.create_users
    before :all do
      @philip_admin = create(:philip, :admin)
      @mike         = create(:mike)
      @stephens     = create(:stephens)
    end

    after :all do
      DatabaseCleaner.clean_with(:deletion)
    end
  end

  it { expect(subject).to use_before_action(:logged_in_user?) }

  describe 'GET #new' do
    before(:each) { get :new }

    it 'assigns a new user to @user' do
      expect(assigns(:user).id).to be_nil
    end

    it { expect(subject).to render_template :new }
  end

  describe 'POST#create' do
    context 'with valid attributes' do
      before :each do |example|
        unless example.metadata[:skip_before]
          post :create, user: attributes_for(:philip)
        end
      end

      it 'creates a new User', skip_before: true do
        expect {
          post :create, user: attributes_for(:philip)
        }.to change(User, :count).by(1)
      end

      it 'sends an account activation email', skip_before: true do
        expect {
          post :create, user: attributes_for(:philip)
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end

      it 'assigns a valid user to @user' do
        expect(assigns(:user)).to be_valid
      end
      it 'sets a logs in the user' do
        expect(session[:user_id]).to eq(assigns(:user).id)
      end

      it { expect(subject).to set_flash[:warning] }
      it { expect(subject).to redirect_to profile_path }
    end

    context 'with valid attributes' do
      context 'with remember_me checked' do
        it 'sets :user_id in the cookie' do
          post :create, user: attributes_for(:user, remember_me: '1')
          expect(cookies.signed[:user_id]).to eq(assigns(:user).id)
        end
      end

      context 'with remember_me not checked' do
        it 'does not set :user_id in the cookie' do
          post :create, user: attributes_for(:user, remember_me: '0')
          expect(cookies.signed[:user_id]).to be_nil
        end
      end
    end

    context 'with invalid attributes' do
      before :each do |example|
        unless example.metadata[:skip_before]
          post :create, user: attributes_for(:user, :invalid_email)
        end
      end

      it 'does not create a new User', skip_before: true do
        expect {
          post :create, user: attributes_for(:user, :invalid_email)
        }.to_not change(User, :count)
      end

      it 'does not send an account activation email', skip_before: true do
        expect {
          post :create, user: attributes_for(:user, :invalid_email)
        }.to_not change(ActionMailer::Base.deliveries, :size)
      end

      it 'assigns an invalid user to @user' do
        expect(assigns(:user)).to_not be_valid
      end

      it { expect(subject).to render_template :new }
    end
  end

  describe 'GET #index' do
    create_users

    context 'when logged in' do
      before(:each) { login(@mike) }

      context 'with no search_term' do
        it 'finds all users' do
          get :index
          expect(assigns(:users)).to eq([@mike, @philip_admin, @stephens])
        end
      end

      context 'with search_term' do
        it 'only finds the matching users' do
          get :index, search_term: 'i'
          expect(assigns(:users)).to eq([@mike, @philip_admin])
        end
      end

      it {
        get :index
        expect(subject).to render_template :index
      }
    end

    context 'when not logged in' do
      before(:each) { get :index }

      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end
  end

  describe 'DELETE #destroy' do
    create_users

    context 'when not logged in' do
      before(:each) { delete :destroy, id: @mike }

      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when logged in as normal @user' do
      before(:each) { login(@mike) }

      context 'when deleting own profile' do
        before :each do |example|
          delete :destroy, id: @mike unless example.metadata[:skip_before]
        end

        it 'deletes the user from database', skip_before: true do
          expect {
            delete :destroy, id: @mike
          }.to change(User, :count).by(-1)
        end

        it { expect(subject).to set_flash[:info] }
        it { expect(subject).to redirect_to root_path }
      end

      context 'when deleting wrong profile' do
        it 'does not delete the user from database' do
          expect {
            delete :destroy, id: @stephens
          }.to_not change(User, :count)
        end
        it 'redirects back' do
          delete :destroy, id: @stephens
          expect(subject).to redirect_to root_path
        end
      end
    end

    context 'when logged in as @philip_admin' do
      # admins can delete anyone
      before(:each) { login(@philip_admin) }
      context 'when deleting own profile' do
        it 'deletes the user from database' do
          expect {
            delete :destroy, id: @philip_admin
          }.to change(User, :count).by(-1)
        end
        it 'redirect_to root_path' do
          delete :destroy, id: @philip_admin
          expect(subject).to redirect_to root_path
        end
      end

      context 'when deleting @stephens profile' do
        it 'deletes the user from database' do
          expect {
            delete :destroy, id: @stephens
          }.to change(User, :count).by(-1)
        end
        it 'redirects_to edit_profile_path' do
          delete :destroy, id: @stephens
          expect(subject).to redirect_to users_path
        end
      end

      context 'when deleting a non-existing user' do
        it 'redirects back' do
          bad_id = User.maximum(:id) + 1
          delete :destroy, id: bad_id
          expect(subject).to respond_with 404
        end
      end
    end
  end
end
