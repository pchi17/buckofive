require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  before(:all) { @user = create(:philip) }

  it { expect(subject).to use_before_action(:logged_in_user?) }
  it { expect(subject).to use_before_action(:is_email_nil?) }

  describe 'GET #edit' do
    context 'when no one is logged in' do
      before(:each) { get :edit }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when @user is logged in' do
      before :each do
        login(@user)
        get :edit
      end

      it 'assigns current_user to @user' do
        expect(assigns(:current_user)).to eq(@user)
      end

      it { expect(subject).to render_template :edit }
    end
  end

  describe 'PATCH #update' do
    context 'when no one is logged in' do
      before(:each) { get :edit }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when @user is logged_in' do
      before(:all) do
        @oldpassword = @user.password
        @newpassword = @oldpassword + 'xxx'
        @invalid_password = 'foo'
        @valid_attrs   = { oldpassword: @oldpassword, password: @newpassword,      password_confirmation: @newpassword }
        @invalid_attrs = { oldpassword: @oldpassword, password: @invalid_password, password_confirmation: @invalid_password }
      end

      before(:each) { login(@user) }

      it 'assigns current_user to @user' do
        patch :update, user: @valid_attrs
        expect(assigns(:current_user)).to eq(@user)
      end

      context 'with valid attributes' do
        before(:each) { patch :update, user: @valid_attrs }

        it { expect(assigns(:current_user).skip_password_validation).to be nil }

        it 'updates current_user password' do
          expect(current_user.reload.authenticate(@newpassword)).to eq(current_user)
          expect(current_user.reload.authenticate(@oldpassword)).to be false
        end

        it { expect(subject).to set_flash[:success] }
        it { expect(subject).to redirect_to edit_profile_password_path }
      end

      context 'with invalid attributes' do
        before(:each) { patch :update, user: @invalid_attrs }

        it { expect(assigns(:current_user).skip_password_validation).to be nil }

        it { expect(subject).to render_template :edit }

        it 'does not update current_user password' do
          expect(current_user.reload.authenticate(@invalid_password)).to be false
          expect(current_user.reload.authenticate(@oldpassword)).to eq(current_user)
        end
      end

      context 'when old password is incorrect' do
        before(:each) do
          patch :update, user: {
            oldpassword: @oldpassword + '123', password: @newpassword, password_confirmation: @newpassword
          }
        end

        it 'adds an error to :oldpassword attribute' do
          expect(assigns(:current_user).errors.size).to eq(1)
        end

        it { expect(subject).to render_template :edit }

        it 'does not update current_user password' do
          expect(current_user.reload.authenticate(@newpassword)).to be false
          expect(current_user.reload.authenticate(@oldpassword)).to eq(current_user)
        end
      end
    end
  end
end
