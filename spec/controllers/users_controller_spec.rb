require 'rails_helper'

RSpec.describe UsersController, type: :controller do
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
    describe 'changes in the data model' do
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
  end
end
