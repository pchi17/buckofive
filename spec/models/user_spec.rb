require 'rails_helper'

RSpec.describe User, type: :model do
  def self.build_user
    before(:all) { @user = build(:user) }
  end

  def self.create_user
    before(:all) { @user = create(:user) }
    after(:all)  { DatabaseCleaner.clean_with(:deletion) }
  end

  def self.check_presence(accessor)
    it 'is not valid when nil' do
      @user.send(accessor, nil)
      expect(@user).to_not be_valid
    end

    it 'is not valid when empty' do
      @user.send(accessor, '')
      expect(@user).to_not be_valid
    end

    it 'is not valid when blank' do
      @user.send(accessor, '   ')
      expect(@user).to_not be_valid
    end
  end

  describe 'factory' do
    it 'is valid' do
      expect(build(:user)).to be_valid
    end
  end

  describe '#name' do
    build_user
    check_presence(:name=)
  end

  describe '#email' do
    build_user
    check_presence(:email=)

    context 'with valid email address' do
      valid_addresses = %w[
        user@example.com
        USER@foobar.com
        COOL_US-ER@foobar.com
        first.last@foobar.io
        cool+user@foobar.com.uk
      ]
      valid_addresses.each do |addr|
        it "is valid - #{addr}" do
          @user.email = addr
          expect(@user).to be_valid
        end
      end
    end

    context 'with invalid email address' do
      invalid_addresses = %w[
        user@example,com
        user_at_foobar.org
        user.name@something.
        user@foo_bar.com
        user@foo+bar.com
        user@foobar..com
      ]
      invalid_addresses.each do |addr|
        it "is not valid - #{addr}" do
          @user.email = addr
          expect(@user).to_not be_valid
        end
      end
    end

    context 'with duplicate email' do
      before :all do
        @user.save
        @valid_email = @user.email
      end

      it 'is not valid' do
        another_user = build(:user, :another_user, email: @valid_email)
        expect(another_user).to_not be_valid
      end

      it 'is not valid regardless of case sensitivity' do
        upcase_email = @valid_email.upcase
        another_user = build(:user, :another_user, email: upcase_email)
        expect(another_user).to_not be_valid
      end
    end

    context 'when saved' do
      it 'saves email in all lower case letters' do
        valid_email = 'USER@Example.com'
        user = create(:user, email: valid_email)
        expect(user.reload.email).to eq(valid_email.downcase)
      end
    end
  end

  describe '#password' do
    build_user

    it 'is not valid when nil' do
      @user.password              = nil
      @user.password_confirmation = nil
      expect(@user).to_not be_valid
    end

    it 'is not valid when empty' do
      @user.password              = ''
      @user.password_confirmation = ''
      expect(@user).to_not be_valid
    end

    it 'is not valid when shorter than 6 characters' do
      @user.password              = 'a' * 5
      @user.password_confirmation = 'a' * 5
      expect(@user).to_not be_valid
    end

    # default BCrypt gem setting
    it 'is not valid when longer than 72 characters' do
      @user.password              = 'a' * 73
      @user.password_confirmation = 'a' * 73
      expect(@user).to_not be_valid
    end

    describe '#password_confirmation' do
      context 'when not matching password' do
        it 'is not valid' do
          @user.password              = 'something'
          @user.password_confirmation = 'no match'
          expect(@user).to_not be_valid
        end
      end
    end
  end

  describe '#authentication' do
    create_user

    before :all do
      @password       = @user.password
      @wrong_password = @password + 'xxx'
    end

    context 'when supplying a non matching password' do
      it 'is not authenticated' do
        expect(@user.authenticate(@wrong_password)).to be false
      end
    end

    context 'when supplying the matching password' do
      it 'returns the user' do
        expect(@user.authenticate(@password)).to eq(@user)
      end
    end
  end

  describe '#remember_me' do
    create_user

    context 'when #remember_me is called' do
      before(:all) { @user.remember_me }

      it 'has the remember_token transient attribute' do
        expect(@user.remember_token).to_not be_nil
      end
      it 'has the remember_digest attribute' do
        expect(@user.remember_digest).to_not be_nil
      end
    end
  end

  describe '#forget_me' do
    create_user
    context 'when user is remembered' do
      it 'sets remember_digest to nil' do
        @user.remember_me
        @user.forget_me
        expect(@user.remember_digest).to be_nil
      end
    end
    context 'when user is not remembered' do
      it 'sets remember_digest to nil' do
        @user.forget_me
        expect(@user.remember_digest).to be_nil
      end
    end
  end

  describe '#create_activation_digest' do
    create_user

    before(:all) { @user.create_activation_digest }

    it 'has the activation_token transient attribute' do
      expect(@user.activation_token).to_not be_nil
    end
    it 'has the activation_digest attribute' do
      expect(@user.activation_digest).to_not be_nil
    end
  end

  describe '#send_activation_email' do
    create_user
    it 'creates and saves an activation_digest' do
      @user.send_activation_email
      expect(@user.activation_digest).to_not be_nil
    end
    it 'sends an activation_email' do
      expect {
        @user.send_activation_email
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end

  describe '#activate_account' do
    create_user
    it 'sets the activated to true' do
      expect(@user.activated?).to be false
      @user.activate_account
      expect(@user.activated?).to be true
    end
  end

  describe '#create_reset_digest' do
    create_user
    before(:all) { @user.create_reset_digest }

    it 'has the reset_token transient attribute' do
      expect(@user.reset_token).to_not be_nil
    end
    it 'has the reset_digest attribute' do
      expect(@user.reset_digest).to_not be_nil
    end
    it 'has the reset_sent_at timestamp' do
      expect(@user.reset_sent_at).to_not be_nil
    end
  end

  describe '#clear_reset_digest' do
    create_user
    before :all do
      @user.create_reset_digest
      @user.clear_reset_digest
    end

    it 'sets reset_digest to nil' do
      expect(@user.reset_digest).to be_nil
    end
    it 'sets reset_sent_at to nil' do
      expect(@user.reset_sent_at).to be_nil
    end
  end

  describe '#send_reset_email' do
    create_user
    it 'creates and saves an reset_digest' do
      @user.send_reset_email
      expect(@user.reset_digest).to_not be_nil
    end
    it 'sends a password reset email' do
      expect {
        @user.send_reset_email
      }.to change(ActionMailer::Base.deliveries, :size).by(1)
    end
  end

  describe '#is_reset_expired?' do
    create_user
    context 'when reset email was sent less than 2 hours ago' do
      it 'returns false' do
        @user.update_columns(reset_sent_at: 1.hour.ago)
        expect(@user.is_reset_expired?).to be false
      end
    end
    context 'when reset email was sent more than 2 hours ago' do
      it 'returns true' do
        @user.update_columns(reset_sent_at: 3.hour.ago)
        expect(@user.is_reset_expired?).to be true
      end
    end
  end

  describe '#is_digest?' do
    create_user
    before :all do
      @user.remember_me
      @user.create_activation_digest
      @user.create_reset_digest
    end

    context 'when passed in :remember' do
      it 'authenticates the :remember_token' do
        expect(@user.is_digest?(:remember, @user.remember_token)).to be true
      end
    end

    context 'when passed in :activation' do
      it 'authenticates the :activation_token' do
        expect(@user.is_digest?(:activation, @user.activation_token)).to be true
      end
    end

    context 'when passed in :reset' do
      it 'authenticates the :reset_token' do
        expect(@user.is_digest?(:reset, @user.reset_token)).to be true
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
