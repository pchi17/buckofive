require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  before(:all) { @user = create(:user) }

  describe 'GET #show' do
    context 'when no one is logged in' do
      before(:each) { get :show }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when @user is logged in' do
      it 'renders :show' do
        login(@user)
        get :show
        expect(subject).to render_template :show
     end
    end
  end

  describe 'GET #edit' do
    context 'when no one is logged in' do
      before(:each) { get :edit }
      it { expect(subject).to set_flash[:info] }
      it { expect(subject).to redirect_to login_path }
    end

    context 'when @user is logged in' do
      it 'renders :show' do
        login(@user)
        get :edit
        expect(subject).to render_template :edit
     end
    end
  end
end
