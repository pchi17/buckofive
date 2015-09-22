require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  before(:all) { @user = create(:philip) }

  it { expect(subject).to use_before_action(:logged_in_user?) }

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
      before(:each) { login(@user) }
      it 'assigns current_user to @user' do
        patch :update, user: { name: 'foo', email: 'foo@bar.com' }
        expect(assigns(:current_user)).to eq(@user)
      end

      context 'with valid attributes' do
        before(:all) do
          @oldname  = @user.name
          @newname  = @oldname + 'xxx'
          @oldemail = @user.email
          @newemail = @oldemail + '.uk'
          @attrs = { name: @newname, email: @newemail }
        end

        before(:each) { patch :update, user: @attrs }

        it 'sets skip_password_validation to true' do
          expect(assigns(:current_user).skip_password_validation).to be true
        end

        it 'updates current_user' do
          expect(current_user.reload.name).to  eq(@newname)
          expect(current_user.reload.email).to eq(@newemail)
        end

        it { expect(subject).to set_flash[:success] }
        it { expect(subject).to redirect_to edit_profile_account_path }
      end

      context 'with invalid attributes' do
        before(:all) { @invalid_email = 'invalid@nil' }
        before(:each) { patch :update, user: { name: @user.name, email: @invalid_email} }

        it 'sets skip_password_validation to true' do
          expect(assigns(:current_user).skip_password_validation).to be true
        end

        it 'does not update current_user' do
          expect(current_user.reload.email).to_not eq(@invalid_email)
        end

        it 'renders :edit' do
          expect(subject).to render_template :edit
        end
      end
    end
  end
end
