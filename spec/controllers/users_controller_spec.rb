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

  describe 'GET#index' do
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
    end

    context 'with invalid attributes' do
      it 'does not create a new User' do
        expect {
          post :create, user: attributes_for(:user, :invalid_email)
        }.to_not change(User, :count)
      end
    end

    context 'with valid attributes' do
      before(:each) { post :create, user: attributes_for(:user) }

      it 'assigns a valid user to @user' do
        expect(assigns(:user)).to be_valid
      end
      it 'sets a session[:user_id]' do
        expect(session[:user_id]).to_not be_nil
      end
      it 'sets a flash[:success] message' do
        expect(flash[:success]).to_not be_nil
      end
      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with invalid attributes' do
      before(:each) { post :create, user: attributes_for(:user, :invalid_email) }
      it 'assigns a invalid user to @user' do
        expect(assigns(:user)).to_not be_valid
      end
      it 're-renders the :new template' do
        expect(response).to render_template :new
      end
    end

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

  describe 'GET #edit' do
    seed_users

    context 'when not logged in' do
      it 'redirect_to login_path' do
        get :edit, id: @user
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as @user' do

      context 'when accessing own edit page' do
        it 'renders the :edit view' do
          login(@user)
          get :edit, id: @user
          expect(response).to render_template :edit
        end
      end

      context 'when accssing wrong edit page' do
        it 'redirect_to root_path' do
          login(@user)
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
    end

    context 'when not logged in' do
      it 'redirect_to login_path' do
        patch :update, id: @user, user: @attrs
        expect(response).to redirect_to login_path
      end
    end

    context 'when logged in as @user' do

      context 'when update own profile' do
        it 'changes the @user attributes' do
          login(@user)
          patch :update, id: @user, user: @attrs
          @user.reload
          expect(@user.name).to eq(@attrs[:name])
        end
      end

      context 'when updating wrong profile' do
        it 'redirect_to root_path' do
          login(@user)
          patch :update, id: @other, user: @attrs
          expect(response).to redirect_to root_path
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    seed_users

    context 'when not logged in' do
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

      context 'when deleting other profile' do
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
