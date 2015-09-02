require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  before(:all)  { @user = create(:user) }
  before(:each) { session.delete(:user_id) }

  describe '#login' do
    it 'sets the session[:user_id] to the id of a user' do
      login(@user)
      expect(session[:user_id]).to eq(@user.id)
    end
  end

  describe '#logged_in?' do
    it 'returns false when no one is logged in' do
      expect(logged_in?).to be false
    end
    it 'returns true when a user is logged in' do
      login(@user)
      expect(logged_in?).to be true
    end
  end

  describe '#current_user' do
    it 'returns nil when no one is logged in' do
      expect(current_user).to be_nil
    end
    it 'returns the logged in user if a user is logged in' do
      login(@user)
      expect(current_user).to eq(@user)
    end
    context 'when remembered' do
      it 'returns the remembered user if the user is not logged in' do
        remember(@user)
        expect(current_user).to eq(@user)
      end
    end
  end

  describe '#remember' do
    it 'sets a signed :user_id in cookies' do
      remember(@user)
      expect(cookies.signed[:user_id]).to eq(@user.id)
    end
    it 'sets the @user.remember_token in cookies' do
      remember(@user)
      expect(@user.is_digest?(:remember, cookies[:remember_token])).to be true
    end
  end
end
