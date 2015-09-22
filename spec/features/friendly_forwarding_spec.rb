require 'rails_helper'

feature 'friendly forwarding' do
  before(:all) { @user = create(:philip) }

  scenario 'user try to visit edit page' do
    # user is not signed in
    visit "/"
    visit edit_profile_path
    # user is redirect_to login_path
    expect(current_path).to eq(login_path)
    within "form" do
      fill_in("session[email]", with: @user.email)
      fill_in("session[password]", with: @user.password)
      click_on("Log In")
    end
    # user is redirect back to edit page instead of root_path
    expect(current_path).to eq(edit_profile_path)
  end
end
