class AccountsController < ApplicationController
  before_action :logged_in_user

  def edit
  end

  def update
    update_current_user('account updated', edit_profile_account_path, true)
  end
end
