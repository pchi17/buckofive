require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  def self.seed_users
    before :all do
      @user  = create(:user)
      @other = create(:user, :another_user)
      @admin = create(:user, :admin)
    end

    after :all do
      DatabaseCleaner.clean_with(:deletion)
    end
  end

  describe 'GET #new' do
    before(:each) { get :new }

    it 'assigns a new user to @user' do
      expect(assigns(:user).id).to be_nil
    end

    it 'renders the :new template' do
      expect(response).to render_template :new
    end
  end

  describe 'POST#create' do

    context 'with valid attributes' do
      it 'creates a new User' do
        expect {
          post :create, user: attributes_for(:user)
        }.to change(User, :count).by(1)
      end
      it 'sends an account activation email' do
        expect {
          post :create, user: attributes_for(:user)
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    context 'with valid attributes' do
      before(:each) { post :create, user: attributes_for(:user) }

      it 'assigns a valid user to @user' do
        expect(assigns(:user)).to be_valid
      end
      it 'sets a logs in the user' do
        expect(session[:user_id]).to eq(assigns(:user).id)
      end
      it 'sets a flash[:info] message' do
        expect(flash[:info]).to_not be_nil
      end
      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
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
      it 'does not create a new User' do
        expect {
          post :create, user: attributes_for(:user, :invalid_email)
        }.to_not change(User, :count)
      end
      it 'does not send an account activation email' do
        expect {
          post :create, user: attributes_for(:user, :invalid_email)
        }.to_not change(ActionMailer::Base.deliveries, :size)
      end
    end

    context 'with invalid attributes' do
      before(:each) { post :create, user: attributes_for(:user, :invalid_email) }

      it 'assigns an invalid user to @user' do
        expect(assigns(:user)).to_not be_valid
      end
      it 're-renders the :new template' do
        expect(response).to render_template :new
      end
    end

  end

  describe 'GET #edit' do
    seed_users

    context 'when not logged in' do
      before(:each) { get :edit, id: @user }

      it 'stores the edit_user_path' do
        expect(session[:forwarding_url]).to eq(edit_user_url(@user))
      end
      it 'sets a flash[:info] message' do
        expect(flash[:info]).to_not be_nil
      end
      it 'redirect_to login_path' do
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as @user' do
      before(:each) { login(@user) }

      context 'when accessing own edit page' do
        it 'renders the :edit view' do
          get :edit, id: @user
          expect(response).to render_template :edit
        end
      end

      context 'when accessing wrong edit page' do
        it 'redirect_to root_path' do
          get :edit, id: @other
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe 'PATCH #update' do
    seed_users

    before :all do
      @attrs = attributes_for(:user)
      @attrs[:name] += 'xxx'
      # changing name from 'philip' to 'philipxxx'
    end

    context 'when not logged in' do
      before(:each) { patch :update, id: @user, user: @attrs }

      it 'does not stores the user_url' do
        # because the request is not a GET
        expect(session[:forwarding_url]).to be_nil
      end
      it 'sets a flash[:info] message' do
        expect(flash[:info]).to_not be_nil
      end
      it 'redirect_to login_path' do
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as @user' do
      before(:each) { login(@user) }

      context 'when update own profile' do
        context 'with valid attributes' do
          before(:each) { patch :update, id: @user, user: @attrs }

          it 'changes the @user attributes' do
            expect(assigns(:user).reload.name).to eq(@attrs[:name])
          end
          it 'sets a flash[:success] message' do
            expect(flash[:success]).to_not be_nil
          end
          it 'redirect_to root_path' do
            expect(response).to redirect_to root_path
          end
        end

        context 'with invalid attributes' do
          before(:all) { @attrs[:email] = '123' } # too short

          it 're-renders the :edit template' do
            patch :update, id: @user, user: @attrs
            expect(response).to render_template :edit
          end
        end
      end

      context 'when update wrong profile' do
        it 'redirect_to root_path' do
          patch :update, id: @other, user: @attrs
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    seed_users

    context 'when not logged in' do
      before(:each) { delete :destroy, id: @user }

      it 'does not stores the user_url' do
        # because the request is not a GET
        expect(session[:forwarding_url]).to be_nil
      end
      it 'sets a flash[:info] message' do
        expect(flash[:info]).to_not be_nil
      end
      it 'redirect_to login_path' do
        delete :destroy, id: @user
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as normal @user' do
      before(:each) { login(@user) }

      context 'when deleting own profile' do
        it 'deletes the user from database' do
          expect {
            delete :destroy, id: @user
          }.to change(User, :count).by(-1)
        end
        it 'sets a flash[:info] message' do
          delete :destroy, id: @user
          expect(flash[:info]).to_not be_nil
        end
        it 'redirect_to root_path' do
          delete :destroy, id: @user
          expect(response).to redirect_to root_path
        end
      end

      context 'when deleting wrong profile' do
        it 'does not delete the user from database' do
          expect {
            delete :destroy, id: @other
          }.to_not change(User, :count)
        end
        it 'redirect_to root_path' do
          delete :destroy, id: @other
          expect(response).to redirect_to root_path
        end
      end
    end

    context 'when logged in as @admin' do
      # admins can delete anyone
      before(:each) { login(@admin) }
      context 'when deleting own profile' do
        it 'deletes the user from database' do
          expect {
            delete :destroy, id: @admin
          }.to change(User, :count).by(-1)
        end
        it 'redirect_to root_path' do
          delete :destroy, id: @admin
          expect(response).to redirect_to root_path
        end
      end

      context 'when deleting @other profile' do
        it 'deletes the user from database' do
          expect {
            delete :destroy, id: @other
          }.to change(User, :count).by(-1)
        end
        it 'redirect_to root_path' do
          delete :destroy, id: @other
          expect(response).to redirect_to root_path
        end
      end
    end
  end
end
