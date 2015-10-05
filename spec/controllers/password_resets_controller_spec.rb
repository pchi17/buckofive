require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  before :all do
    @user = create(:philip, :with_account)
    @user.create_reset_digest
    @old_password = @user.account.password
    @new_password = @old_password + 'xxx'
  end

  it { expect(subject).to use_before_action(:get_user) }
  it { expect(subject).to use_before_action(:valid_user?) }
  it { expect(subject).to use_before_action(:is_link_expired?) }

  describe 'GET #new' do
    it 'renders the :new view' do
      get :new
      expect(subject).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with a registered email' do
      before(:each) { post :create, password_reset: { email: @user.email } }

      it { expect(assigns(:user)).to eq(@user) }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path}
    end

    context 'with a registered email' do
      it 'queues a ResetMailWorker' do
        expect {
          post :create, password_reset: { email: @user.email }
        }.to change { ResetMailWorker.jobs.size }.by(1)
      end
    end

    context 'with a non registered email' do
      before(:each) { post :create, password_reset: { email: @user.email + 'xxx' } }

      it { expect(assigns(:user)).to be_nil }
      it { expect(subject).to set_flash[:danger] }
      it { expect(subject).to render_template :new }
    end
  end

  describe 'GET #edit' do
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
          @user.account.update_columns(reset_sent_at: 3.hour.ago)
          get :edit, id: @user.reset_token, email: @user.email
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to new_password_reset_path }
      end
    end

    context 'with invalid reset_token' do
      before :each do
        get :edit, id: @user.reset_token + 'xxx', email: @user.email
      end

      it { expect(subject).to set_flash[:danger] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'with invalid email' do
      before :each do
        get :edit, id: @user.reset_token, email: @user.email + 'xxx'
      end

      it { expect(subject).to set_flash[:danger] }
      it { expect(subject).to redirect_to login_path }
    end
  end

  describe 'PATCH #update' do
    def self.it_does_not_reset_password
      it 'does not reset password' do
        expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
      end
    end

    context 'with valid reset_token and email' do
      context 'when reset link is not expired' do
        context 'when password and confirmation matches and are valid' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              account: { password: @new_password, password_confirmation: @new_password }
          end

          it 'updates the password' do
            expect(assigns(:user).reload.authenticate(@new_password)).to eq(@user)
          end

          it 'logs in the user' do
            expect(session[:user_id]).to eq(@user.id)
          end

          it { expect(subject).to set_flash[:success] }
          it { expect(subject).to redirect_to root_path }
        end

        context 'when password and confirmation do not match' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              account: { password: @new_password, password_confirmation: @new_password + 'xxx' }
          end

          it 'does not reset password' do
            expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
          end

          it { expect(subject).to render_template :edit }
        end

        context 'when password is nil' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              account: { password: nil, password_confirmation: nil }
          end

          it 'does not reset password' do
            expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
          end

          it { expect(subject).to render_template :edit }
        end

        context 'when password is empty' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              account: { password: '', password_confirmation: '' }
          end

          it 'does not reset password' do
            expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
          end

          it { expect(subject).to render_template :edit }
        end

        context 'when password is blank' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
            account: { password: ' ' * 7, password_confirmation: ' ' * 7 }
          end

          it 'does not reset password' do
            expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
          end

          it { expect(subject).to render_template :edit }
        end

        context 'when password is too short' do
          before :each do
            patch :update, id: @user.reset_token, email: @user.email,
              account: { password: '12345', password_confirmation: '12345' }
          end

          it 'does not reset password' do
            expect(assigns(:user).reload.authenticate(@old_password)).to eq(@user)
          end

          it { expect(subject).to render_template :edit }
        end
      end

      context 'when reset link is expired' do
        before :each do
          @user.account.update_columns(reset_sent_at: 3.hour.ago)
          patch :update, id: @user.reset_token, email: @user.email,
            account: { password: @new_password, password_confirmation: @new_password }
        end

        it { expect(subject).to set_flash[:warning] }
        it { expect(subject).to redirect_to new_password_reset_path }
      end
    end

    context 'with invalid reset_token' do
      before :each do
        patch :update, id: @user.reset_token + 'xxx', email: @user.email,
          account: { password: @new_password, password_confirmation: @new_password }
      end

      it { expect(subject).to set_flash[:danger] }
    end

    context 'with invalid email' do
      before :each do
        patch :update, id: @user.reset_token, email: @user.email + 'xxx',
          account: { password: @new_password, password_confirmation: @new_password }
      end

      it { expect(subject).to set_flash[:danger] }
    end
  end
end
