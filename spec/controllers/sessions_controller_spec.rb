require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  before(:all) { @user = create(:user) }

  describe 'GET #new' do
    it 'renders the :new template' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid email and password' do
      before(:all) do
        @attrs = { email: @user.email, password: @user.password }
      end

      before(:each) { post :create, session: @attrs }

      it 'returns the @user with the given email' do
        expect(assigns(:user).email).to eq(@attrs[:email])
      end

      it 'authenticates the @user' do
        expect(assigns(:user).authenticate(@attrs[:password])).to eq(@user)
      end

      it 'sets session[:user_id] to @user.id' do
        expect(session[:user_id]).to eq(assigns(:user).id)
      end
      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with valid email and password' do
      context 'with remember_me checked' do
        it 'sets :user_id in cookies' do
          post :create, session: { email: @user.email, password: @user.password, remember_me: '1'}
          expect(cookies.signed[:user_id]).to eq(assigns(:user).id)
        end
      end

      context 'with remember_me not checked' do
        it 'does not set :user_id in the cookies' do
          post :create, session: { email: @user.email, password: @user.password, remember_me: '0'}
          expect(cookies.signed[:user_id]).to be_nil
        end
      end
    end

    context 'with non-existent email' do
      before(:all) do
        @attrs = { email: @user.email + 'xxx', password: @user.password }
      end

      before(:each) { post :create, session: @attrs }

      it 'returns nil for @user' do
        expect(assigns(:user)).to be_nil
      end

      it 'sets a flash.now[:danger] message' do
        expect(flash.now[:danger]).to_not be_nil
      end

      it 're-renders the :new template' do
        expect(response).to render_template :new
      end
    end

    context 'with wrong password' do
      before(:all) do
        @attrs = { email: @user.email, password: @user.password + 'xxx' }
      end

      before(:each) { post :create, session: @attrs }

      it 'returns the @user with given email' do
        expect(assigns(:user).email).to eq(@attrs[:email])
      end

      it 'does not authenticate the @user' do
        expect(assigns(:user).authenticate(@attrs[:password])).to be false
      end

      it 'sets a flash.now[:danger] message' do
        expect(flash.now[:danger]).to_not be_nil
      end

      it 're-renders the :new template' do
        expect(response).to render_template :new
      end
    end
  end

  describe 'DELETE #destroy' do
    before(:each) { login(@user) }

    it 'deletes session[user_id]' do
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
    it 'sets current_user to nil' do
      delete :destroy
      expect(current_user).to be_nil
    end
    it 'redirect_to root_path' do
      delete :destroy
      expect(response).to redirect_to root_path
    end

    context 'when remember_me is enabled' do
      before(:each) do
        remember(@user)
        delete :destroy
      end

      it 'deletes the :user_id stored in cookies' do
        expect(cookies.signed[:user_id]).to be_nil
      end
      it 'deletes the :remember_token in cookies' do
        expect(cookies[:remember_token]).to be_nil
      end
    end
  end
end
