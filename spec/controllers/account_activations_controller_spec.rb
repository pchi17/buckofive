require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  def self.setup
    before :all do
      @user = create(:user)
      @user.create_activation_digest
    end
    after :all do
      DatabaseCleaner.clean_with(:deletion)
    end
  end

  describe '#edit' do
    context 'when @user is created' do
      it 'checks that @user is not activated' do
        user = create(:user)
        expect(user.activated?).to be false
      end
    end

    context 'with valid activation_token and email' do
      setup
      before(:each) { get :edit, id: @user.activation_token, email: @user.email }

      it 'activates the user' do
        @user.reload
        expect(@user.activated?).to be true
      end

      it 'sets a flash[:success] message' do
        expect(flash[:success]).to_not be_nil
      end

      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with invalid activation_token' do
      setup
      before(:each) { get :edit, id: @user.activation_token + 'xxx', email: @user.email }

      it 'does not activate the user' do
        expect(@user.activated?).to be false
      end

      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
    end

    context 'with invalid email' do
      setup
      before(:each) { get :edit, id: @user.activation_token, email: @user.email + 'xxx' }

      it 'does not activate the user' do
        expect(@user.activated?).to be false
      end

      it 'redirect_to root_path' do
        expect(response).to redirect_to root_path
      end
    end
  end
end
