module ProfilesHelper
  def update_current_user(flash_msg, redirect_path, skip_password_validation = false)
    current_user.skip_password_validation = skip_password_validation
    if current_user.update_attributes(user_params)
      flash[:success] = flash_msg
      redirect_to redirect_path
    else
      render :edit
    end
  end
end
