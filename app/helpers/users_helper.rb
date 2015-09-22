module UsersHelper
  private
    def activated_current_user?
      unless current_user.activated
        flash[:warning]  = "please activated your account first, "
        flash[:warning] += "you can activate your account by email or by sync with twitter."
        redirect_to edit_profile_path
      end
    end

    def user_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation
      )
    end
end
