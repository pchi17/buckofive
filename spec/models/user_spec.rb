require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe '#name' do
    it { expect(subject).to validate_presence_of :name }
  end

  describe '#email' do
    it { expect(subject).to validate_presence_of :email }
    it { expect(subject).to validate_uniqueness_of(:email).case_insensitive }

    valid_addresses = %w[
      user@example.com
      USER@foobar.com
      COOL_US-ER@foobar.com
      first.last@foobar.io
      cool+user@foobar.com.uk
    ]
    invalid_addresses = %w[
      user@example,com
      user_at_foobar.org
      user.name@something.
      user@foo_bar.com
      user@foo+bar.com
      user@foobar..com
    ]

    it { expect(subject).to     allow_value(*valid_addresses).for(:email) }
    it { expect(subject).to_not allow_value(*invalid_addresses).for(:email) }

    context 'when saved' do
      it 'saves email in all lower case letters' do
        upcase_email = 'UPCASE@example.COM'
        subject.email = upcase_email
        subject.save
        expect(subject.reload.email).to eq(upcase_email.downcase)
      end
    end
  end

  describe '#password' do
    it { expect(subject).to validate_presence_of :password }
    it { expect(subject).to validate_length_of(:password).is_at_least(6) }
    it { expect(subject).to validate_length_of(:password).is_at_most(32) }
    it { expect(subject).to validate_confirmation_of :password }

    context 'when skip_password_validation is true' do
      it 'does not validate password' do
        subject.skip_password_validation = true
        subject.password = nil
        expect(subject).to be_valid
        subject.password = 'foo'
        expect(subject).to be_valid
        subject.password = 'foobar'
        subject.password_confirmation = 'notfoobar'
        expect(subject).to be_valid
      end
    end
  end

  describe '#remember_me' do
    it 'has the remember_token and remember_digest attributes' do
      subject.save
      subject.remember_me
      expect(subject.remember_token).to_not  be_nil
      expect(subject.remember_digest).to_not be_nil
    end
  end

  describe '#forget_me' do
    context 'when user is remembered' do
      it 'sets remember_digest to nil' do
        subject.save
        subject.remember_me
        subject.forget_me
        expect(subject.remember_digest).to be_nil
      end
    end
    context 'when user is not remembered' do
      it 'sets remember_digest to nil' do
        subject.save
        subject.forget_me
        expect(subject.remember_digest).to be_nil
      end
    end
  end

  describe '#create_activation_digest' do
    it 'has the activation_token and activation_digest attributes' do
      subject.save
      subject.create_activation_digest
      expect(subject.activation_token).to_not be_nil
      expect(subject.activation_digest).to_not be_nil
    end
  end

  describe '#send_activation_email' do
    it 'creates and saves an activation_digest' do
      subject.save
      subject.send_activation_email
      expect(subject.activation_digest).to_not be_nil
    end
    it 'sends an activation_email' do
      subject.save
      expect {
        subject.send_activation_email
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end

  describe '#activate_account' do
    it 'sets the activated to true' do
      subject.save
      expect(subject.activated?).to be false
      subject.activate_account
      expect(subject.activated?).to be true
    end
  end

  describe '#create_reset_digest' do
    it 'has reset_token, reset_digest, and reset_sent_at attributes' do
      subject.save
      subject.create_reset_digest
      expect(subject.reset_token).to_not   be_nil
      expect(subject.reset_digest).to_not  be_nil
      expect(subject.reset_sent_at).to_not be_nil
    end
  end

  describe '#clear_reset_digest' do
    it 'sets reset_digest and reset_sent_at o nil' do
      subject.save
      subject.create_reset_digest
      subject.clear_reset_digest
      expect(subject.reset_digest).to  be_nil
      expect(subject.reset_sent_at).to be_nil
    end
  end

  describe '#send_reset_email' do
    it 'creates and saves an reset_digest' do
      subject.save
      subject.send_reset_email
      expect(subject.reset_digest).to_not be_nil
    end
    it 'sends a password reset email' do
      subject.save
      expect {
        subject.send_reset_email
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end

  describe '#is_reset_expired?' do
    context 'when reset email was sent less than 2 hours ago' do
      it 'returns false' do
        subject.save
        subject.update_columns(reset_sent_at: 1.hour.ago)
        expect(subject.is_reset_expired?).to be false
      end
    end
    context 'when reset email was sent more than 2 hours ago' do
      it 'returns true' do
        subject.save
        subject.update_columns(reset_sent_at: 3.hour.ago)
        expect(subject.is_reset_expired?).to be true
      end
    end
  end

  describe '#is_digest?' do
    context 'when passed in :remember' do
      it 'authenticates the :remember_token' do
        subject.save
        subject.remember_me
        expect(subject.is_digest?(:remember, subject.remember_token)).to be true
      end
    end

    context 'when passed in :activation' do
      it 'authenticates the :activation_token' do
        subject.save
        subject.create_activation_digest
        expect(subject.is_digest?(:activation, subject.activation_token)).to be true
      end
    end

    context 'when passed in :reset' do
      it 'authenticates the :reset_token' do
        subject.save
        subject.create_reset_digest
        expect(subject.is_digest?(:reset, subject.reset_token)).to be true
      end
    end
  end

  describe '#has_authentication' do
    context 'when user has an authentication from provider' do
      it 'returns true' do
        subject.save
        auth = create(:authentication, user: subject)
        provider = auth.provider
        expect(subject.has_authentication(provider)).to be true
      end
    end

    context 'when user does not have an authentication from provider' do
      it 'returns false' do
        subject.save
        expect(subject.has_authentication('twitter')).to be false
        auth = create(:authentication, user: subject, provider: 'facebook')
        expect(subject.has_authentication('twitter')).to be false
      end
    end
  end

  # class methods
  describe '::new_token' do
    it 'generates a new token' do
      expect(User.new_token).to_not be_nil
    end
  end

  describe '::digest' do
    it 'generates a digest for a given password' do
      password      = 'foobar'
      password_hash = User.digest(password)
      expect(BCrypt::Password.new(password_hash).is_password?(password)).to be true
    end
  end
end
