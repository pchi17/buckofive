require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  before(:all) { @user = create(:philip) }

  describe "account_activation" do
    before :all do
      @user.create_activation_digest
      @mail = UserMailer.account_activation(@user)
    end

    context 'when rendering header' do
      it 'renders the correct subject' do
        expect(@mail.subject).to eq('Account Activation')
      end
      it 'renders the correct sender' do
        expect(@mail.from).to eq(['noreply@buckofive.herokuapps.com'])
      end
      it 'renders the correct receiver' do
        expect(@mail.to).to eq([@user.email])
      end
    end

    context 'when rendering body' do
      it 'contains the activation_token' do
        expect(@mail.body.encoded).to match(@user.activation_token)
      end
      it 'contains the @user.email' do
        expect(@mail.body.encoded).to match(CGI::escape(@user.email))
      end
    end
  end

  describe "password_reset" do
    before :all do
      @user.create_reset_digest
      @mail = UserMailer.password_reset(@user)
    end

    context 'when rendering header' do
      it 'renders the correct subject' do
        expect(@mail.subject).to eq('Password Reset')
      end
      it 'renders the correct sender' do
        expect(@mail.from).to eq(['noreply@buckofive.herokuapps.com'])
      end
      it 'renders the correct receiver' do
        expect(@mail.to).to eq([@user.email])
      end
    end

    context 'when rendering the body' do
      it 'contains the reset_token' do
        expect(@mail.body.encoded).to match(@user.reset_token)
      end
      it 'contains the @user.email' do
        expect(@mail.body.encoded).to match(CGI::escape(@user.email))
      end
    end
  end
end
