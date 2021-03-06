# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def account_activation
    user = User.find(1)
    UserMailer.account_activation(user)
  end
  
  def password_reset
    user = User.find(1)
    UserMailer.password_reset(user)
  end

end
