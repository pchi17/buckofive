require 'rails_helper'

shared_context 'check presence' do
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
end

shared_context 'user model methods' do
  def self.build_new_user
    before(:all) { @user = build(:user) }
  end

  def self.create_new_user
    before(:all) { @user = create(:user) }
    after(:all)  { DatabaseCleaner.clean_with(:deletion) }
  end
end

RSpec.describe User, type: :model do
  include_context 'check presence'
  include_context 'user model methods'

  describe 'factory' do
    build_new_user
    it 'is valid' do
      expect(@user).to be_valid
    end
  end

  describe '#name' do
    build_new_user
    check_presence(:name=)
  end

  describe '#email' do
    build_new_user
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
      create_new_user
      before(:all) { @valid_email = @user.email }

      it 'is not valid' do
        another_user = build(:user, email: @valid_email)
        expect(another_user).to_not be_valid
      end

      it 'is not valid regardless of case sensitivity' do
        upcase_email = @valid_email.upcase
        expect(upcase_email).to_not eq(@valid_email)
        another_user = build(:user, email: upcase_email)
        expect(another_user).to_not be_valid
      end
    end

    context 'when saved' do
      it 'saves email in all lower case letters' do
        valid_email = 'USER@Example.com'
        @user.email = valid_email
        @user.save
        expect(@user.reload.email).to eq(valid_email.downcase)
      end
    end
  end

  describe '#password' do
    build_new_user

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
      context 'when nil' do
        it 'is valid when not nil or empty' do
          @user.password_confirmation = nil
          @user.password = 'anything not nil or empty'
          expect(@user).to be_valid
        end
      end

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
    create_new_user
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

  describe '#remember_me' do
    context 'when the user is created' do
      build_new_user
      it 'does not have the remember_token transient attribute' do
        expect(@user.remember_token).to be_nil
      end
      it 'does not have the remember_digest attribute' do
        @user.save
        expect(@user.remember_digest).to be_nil
      end
    end

    context 'when #remember_me is called' do
      create_new_user
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
    create_new_user
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
    context 'when the user is created' do
      build_new_user
      it 'does not have the activation_token transient attribute' do
        expect(@user.activation_token).to be_nil
      end
      it 'does not have the activation_digest attribute' do
        @user.save
        expect(@user.activation_digest).to be_nil
      end
    end

    context 'when #create_activation_digest is called' do
      create_new_user
      before(:all) { @user.create_activation_digest }
      it 'has the activation_token transient attribute' do
        expect(@user.activation_token).to_not be_nil
      end
      it 'has the activation_digest attribute' do
        expect(@user.activation_digest).to_not be_nil
      end
    end
  end
end
