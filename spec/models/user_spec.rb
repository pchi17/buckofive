require 'rails_helper'

shared_context 'user model shared methods' do
  def self.build_new_user
    before(:all) { @user = build(:user) }
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
end

RSpec.describe User, type: :model do
  include_context 'user model shared methods'

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
      before :all do
        @valid_email = 'user@example.com'
        @user.email  = @valid_email
        @user.save
      end

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
      it 'saved email in all lower case letters' do
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

    describe '#authentication' do
      before :all do
        @password = 'superfoobar'
        @user.password              = @password
        @user.password_confirmation = @password
        @user.save
      end
      context 'when supplying a non matching password' do
        it 'is not authenticated' do
          expect(@user.authenticate('notsofoobar')).to be false
        end
      end

      context 'when supplying the matching password' do
        it 'returns the user' do
          expect(@user.authenticate(@password)).to eq(@user)
        end
      end
    end
  end
end
