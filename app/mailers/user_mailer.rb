class UserMailer < ApplicationMailer
  def account_activation(user)
    message = {
      to: [ { name: user.name, email: user.email } ],
      subject: 'Account Activation',
      merge_vars: [
        {
          rcpt: user.email,
          vars: [
            { name: 'USER_NAME',      content: user.name },
            { name: 'ACTIVATION_URL', content: edit_account_activation_url(user.activation_token, email: user.email) }
          ]
        }
      ]
    }
    mandrill_client.messages.send_template('account-activation', [], message)
  end

  def password_reset(user)
    message = {
      to: [ { name: user.name, email: user.email } ],
      subject: 'Password Reset',
      merge_vars: [
        {
          rcpt: user.email,
          vars: [
            { name: 'USER_NAME', content: user.name },
            { name: 'RESET_URL', content: edit_password_reset_url(user.reset_token, email: user.email) },
            { name: 'RESET_SENT_TIME', content: user.reset_sent_at.to_formatted_s(:long) }
          ]
        }
      ]
    }
    mandrill_client.messages.send_template('password-reset', [], message)
  end
end
