require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  before :all do
    @user = create(:user)
    @user.create_reset_digest
    @old_password = @user.password
    @new_password = @old_password + 'xxx'
  end

  describe 'GET #new' do
    it 'renders the :new view' do
      get :new
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with a registered email' do
      before(:each) { post :create, password_reset: { email: @user.email } }

      it 'returns the correct @user' do
        expect(assigns(:user)).to eq(@user)
      end

      it 'sets a flash[:info] message' do
        expect(flash[:info]).to_not be_nil
      end

      it 'redirect_to login_path' do
        expect(response).to redirect_to login_path
      end
    end

    context 'with a registered email' do
      it 'sends a password_reset email' do
        expect {
          post :create, password_reset: { email: @user.email }
        }.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    context 'with a non registered email' do
      before(:each) { post :create, password_reset: { email: @user.email + 'xxx' } }

      it 'returns nil for @user' do
        expect(assigns(:user)).to be_nil
      end

      it 'sets a flash[:danger] message' do
        expect(flash[:danger]).to_not be_nil
      end

      it 're-renders the :new template' do
        expect(response).to render_template :new
      end
    end

    context 'with a non registered email' do
      it 'does not send a password_reset email' do
        expect {
          post :create, password_reset: { email: @user.email + 'xxx' }
        }.to_not change(ActionMailer::Base.deliveries, :size)
      end
    end
  end

  describe 'GET #edit' do
    def self.it_sets_flash_danger_message
      it 'sets a flash[:danger] message' do
        expect(flash[:danger]).to_not be_nil
      end
    end

    def self.it_redirects_to_login
      it 'redirect_to login_path' do
        expect(response).to redirect_to login_path
      end
    end

    context 'with valid reset_token and email' do
      it 'finds the correct user' do
        get :edit, id: @user.reset_token, email: @user.email
        expect(assigns(:user)).to eq(@user)
      end
    end

    context 'with valid reset_token and email' do
      context 'with link not expired' do
        it 'renders the edit template' do
          get :edit, id: @user.reset_token, email: @user.email
          expect(response).to render_template :edit
        end
      end

      context 'with link expired' do
        before(:each) do
          @user.update_columns(reset_sent_at: 3.hour.ago)
          get :edit, id: @user.reset_token, email: @user.email
        end

        it 'sets flash[:warning] message' do
          expect(flash[:warning]).to_not be_nil
        end

        it 'redirect_to new_password_reset_path' do
          expect(response).to redirect_to new_password_reset_path
        end
      end
    end

    context 'with invalid reset_token' do
      before :each do
        get :edit, id: @user.reset_token + 'xxx', email: @user.email
      end

      it_sets_flash_danger_message
      it_redirects_to_login
    end

    context 'with invalid email' do
      before :each do
        get :edit, id: @user.reset_token, email: @user.email + 'xxx'
      end

      it_sets_flash_danger_message
      it_redirects_to_login
    end
  end

  describe 'PATCH #update' do
    def self.it_does_not_reset_password
      it 'does not reset password' do
        expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
      end
    end

    def self.it_renders_edit_template
      it 're-renders :edit template' do
        expect(response).to render_template :edit
      end
    end

    def self.it_sets_flash_danger_message
      it 'sets flash[:danger] message' do
        expect(flash[:danger]).to_not be_nil
      end
    end

    context 'with valid reset_token and email' do
      context 'when reset link is not expired' do
        context 'when password and confirmation matches and are valid' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              user: { password: @new_password, password_confirmation: @new_password }
          end
          it 'updates the password' do
            expect(assigns(:user).reload.authenticate(@new_password)).to eq(@user)
          end
          it 'logs in the user' do
            expect(session[:user_id]).to eq(@user.id)
          end
          it 'sets a flash[:success] message' do
            expect(flash[:success]).to_not be_nil
          end
          it 'redirect_to root_path' do
            expect(response).to redirect_to root_path
          end
        end

        context 'when password and confirmation do not match' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              user: { password: @new_password, password_confirmation: @new_password + 'xxx' }
          end

          it_does_not_reset_password
          it_renders_edit_template
        end

        context 'when password is nil' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              user: { password: nil, password_confirmation: nil }
          end

          it_does_not_reset_password
          it_renders_edit_template
        end

        context 'when password is empty' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              user: { password: '', password_confirmation: '' }
          end

          it_does_not_reset_password
          it_renders_edit_template
        end

        context 'when password is blank' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
            user: { password: ' ' * 7, password_confirmation: ' ' * 7 }
          end

          it_does_not_reset_password
          it_renders_edit_template
        end

        context 'when password is too short' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              user: { password: '12345', password_confirmation: '12345' }
          end

          it_does_not_reset_password
          it_renders_edit_template
        end
      end

      context 'when reset link is expired' do
        before :each do
          @user.update_columns(reset_sent_at: 3.hour.ago)
          patch :update, id: @user.reset_token, email: @user.email,
            user: { password: @new_password, password_confirmation: @new_password }
        end

        it 'sets flash[:warning] message' do
          expect(flash[:warning]).to_not be_nil
        end
        it 'redirect_to new_password_reset_path' do
          expect(response).to redirect_to new_password_reset_path
        end
      end
    end

    context 'with invalid reset_token' do
      before :each do
        patch :update, id: @user.reset_token + 'xxx', email: @user.email,
          user: { password: @new_password, password_confirmation: @new_password }
      end

      it_sets_flash_danger_message
    end

    context 'with invalid email' do
      before :each do
        patch :update, id: @user.reset_token, email: @user.email + 'xxx',
          user: { password: @new_password, password_confirmation: @new_password }
      end
      
      it_sets_flash_danger_message
    end
  end
end
