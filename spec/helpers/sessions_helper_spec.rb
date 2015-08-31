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
  before(:all) { @test_user = create(:user) }
  before(:each) { session.delete(:user_id) }

  describe '#login' do
    it 'sets the session[:user_id] to the id of a user' do
      expect(session[:user_id]).to be_nil
      login(@test_user)
      expect(session[:user_id]).to eq(@test_user.id)
    end
  end

  describe '#logged_in?' do
    it 'returns false when no one is logged in' do
      expect(session[:user_id]).to be_nil
      expect(logged_in?).to be false
    end
    it 'returns true when a user is logged in' do
      login(@test_user)
      expect(logged_in?).to be true
    end
  end

  describe '#current_user' do
    it 'returns nil when no one is logged in' do
      expect(session[:user_id]).to be_nil
      expect(current_user).to be_nil
    end
    it 'returns the logged in user if a user is logged in' do
      login(@test_user)
      expect(current_user).to eq(@test_user)
    end
  end

  describe '#logged_in_and_activated?' do
    it 'returns false when no one is logged in' do
      expect(session[:user_id]).to be_nil
      expect(logged_in_and_activated?).to be false
    end
    it 'returns false when logged in user is not activated' do
      @test_user.activated = false
      login(@test_user)
      expect(session[:user_id]).to_not be_nil
      expect(logged_in_and_activated?).to be false
    end
    it 'returns true when current user is activated' do
      @test_user.activated = true
      @test_user.save!
      login(@test_user)
      expect(session[:user_id]).to_not be_nil
      expect(logged_in_and_activated?).to be true
    end
  end
end
