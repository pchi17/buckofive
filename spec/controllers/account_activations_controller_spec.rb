require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  before :all do
    @user  = create(:user)
    @other = create(:user, :another_user)
    @user.create_activation_digest
  end

  describe 'POST #create' do
    context 'when not logged in' do
      it 'does not send an activation email' do
        expect {
          post :create, id: @user
        }.to_not change(ActionMailer::Base.deliveries, :size)
      end

      it 'sets a flash[:info] message' do
        post :create, id: @user
        expect(subject).to set_flash[:info]
      end

      it 'redirect_to login_path' do
        post :create, id: @user
        expect(subject).to redirect_to login_path
      end
    end

    context 'when logged in' do
      before(:each) { login(@user) }

      context 'when posting to self' do
        before(:each) { request.env['HTTP_REFERER'] = edit_user_url(@user) }

        it 'sends an activation email' do
          expect {
            post :create, id: @user
          }.to change(ActionMailer::Base.deliveries, :size).by(1)
        end

        it 'sets a flash[:info] message' do
          post :create, id: @user
          expect(subject).to set_flash[:info]
        end

        it 'redirect_to :back' do
          post :create, id: @user
          expect(subject).to redirect_to request.env['HTTP_REFERER']
        end
      end

      context 'when posting to other' do
        it 'does not send an activation email' do
          expect {
            post :create, id: @other
          }.to_not change(ActionMailer::Base.deliveries, :size)
        end

        it 'redirect_to root_path' do
          post :create, id: @other
          expect(subject).to redirect_to root_path
        end
      end
    end
  end

  describe 'GET #edit' do
    context 'when @user is created' do
      it 'checks that @user is not activated' do
        expect(@user.activated?).to be false
      end
    end

    context 'with valid activation_token and email' do
      context 'when the user is already activated' do
        before(:each) do
          @user.activate_account
          get :edit, id: @user.activation_token, email: @user.email
        end

        it 'finds the correct @user' do
          expect(assigns(:user)).to eq(@user)
        end

        it 'sets a flash[:info] message' do
          expect(subject).to set_flash[:info]
        end

        it 'redirect_to root_path' do
          expect(subject).to redirect_to root_path
        end
      end

      context 'when the user is not activated' do
        before(:each) { get :edit, id: @user.activation_token, email: @user.email }

        it 'finds the correct @user' do
          expect(assigns(:user)).to eq(@user)
        end

        it 'activates the user' do
          expect(assigns(:user).reload.activated?).to be true
        end

        it 'sets a flash[:success] message' do
          expect(subject).to set_flash[:success]
        end

        it 'redirect_to root_path' do
          expect(subject).to redirect_to root_path
        end
      end
    end

    context 'with invalid activation_token' do
      before(:each) { get :edit, id: @user.activation_token + 'xxx', email: @user.email }

      it 'does not activate the user' do
        expect(assigns(:user).reload.activated?).to be false
      end

      it 'redirect_to root_path' do
        expect(subject).to redirect_to root_path
      end
    end

    context 'with invalid email' do
      before(:each) { get :edit, id: @user.activation_token, email: @user.email + 'xxx' }

      it 'returns nil for @user' do
        expect(assigns(:user)).to be_nil
      end

      it 'redirect_to root_path' do
        expect(subject).to redirect_to root_path
      end
    end
  end
end
