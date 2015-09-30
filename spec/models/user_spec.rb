# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  email      :string
#  image      :string
#  admin      :boolean          default(FALSE)
#  activated  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:philip, :with_account) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'associations' do
    it { expect(subject).to have_one :account }
    it { expect(subject).to have_many :authentications }
    it { expect(subject).to have_many :polls }
    it { expect(subject).to have_many :choices }
    it { expect(subject).to have_many :votes }
    it { expect(subject).to accept_nested_attributes_for(:account) }
  end

  describe 'validations' do
    it { expect(subject).to validate_presence_of :name }
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

    it 'validates user has_account' do
      user = build(:mike)
      expect(user).to be_invalid
      expect(user.errors.messages[:account]).to_not be_nil
      user.build_account
      expect(user).to be_invalid # must have valid password and confirmation
      expect(user.errors.messages[:'account.password']).to_not be_nil
      user.build_account(password: 'foobar', password_confirmation: 'foobar')
      expect(user).to be_valid
    end
  end

  describe '#email' do
    context 'when saved' do
      it 'saves email in all lower case letters' do
        upcase_email = 'UPCASE@example.COM'
        subject.email = upcase_email
        subject.save
        expect(subject.reload.email).to eq(upcase_email.downcase)
      end
    end
  end

  describe '#remember_me' do
    it 'has the remember_token and account has remember_digest' do
      subject.save
      subject.remember_me
      expect(subject.remember_token).to_not  be_nil
      expect(subject.account.remember_digest).to_not be_nil
    end
  end

  describe '#forget_me' do
    context 'when user is remembered' do
      it 'sets account remember_digest to nil' do
        subject.save
        subject.remember_me
        subject.forget_me
        expect(subject.account.remember_digest).to be_nil
      end
    end
    context 'when user is not remembered' do
      it 'sets account remember_digest to nil' do
        subject.save
        subject.forget_me
        expect(subject.account.remember_digest).to be_nil
      end
    end
  end

  describe '#create_activation_digest' do
    it 'has the activation_token and account activation_digest' do
      subject.save
      subject.create_activation_digest
      expect(subject.activation_token).to_not be_nil
      expect(subject.account.activation_digest).to_not be_nil
    end
  end

  describe '#send_activation_email' do
    it 'creates and saves an activation_digest in account table' do
      subject.save
      subject.send_activation_email
      expect(subject.account.activation_digest).to_not be_nil
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
    it 'has reset_token, account has reset_digest, and reset_sent_at' do
      subject.save
      subject.create_reset_digest
      expect(subject.reset_token).to_not   be_nil
      expect(subject.account.reset_digest).to_not  be_nil
      expect(subject.account.reset_sent_at).to_not be_nil
    end
  end

  describe '#clear_reset_digest' do
    it 'sets account reset_digest and reset_sent_at o nil' do
      subject.save
      subject.create_reset_digest
      subject.clear_reset_digest
      expect(subject.account.reset_digest).to  be_nil
      expect(subject.account.reset_sent_at).to be_nil
    end
  end

  describe '#send_reset_email' do
    it 'creates and saves an reset_digest' do
      subject.save
      subject.send_reset_email
      expect(subject.account.reset_digest).to_not be_nil
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
        subject.account.update_columns(reset_sent_at: 1.hour.ago)
        expect(subject.is_reset_expired?).to be false
      end
    end
    context 'when reset email was sent more than 2 hours ago' do
      it 'returns true' do
        subject.save
        subject.account.update_columns(reset_sent_at: 3.hour.ago)
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

  describe '::search' do
    before(:all) do
      @philip   = create(:philip,   :with_account)
      @mike     = create(:mike,     :with_account)
      @stephens = create(:stephens, :with_account)
    end

    after(:all) { DatabaseCleaner.clean_with(:deletion) }

    context 'with no search_term' do
      it 'finds all users' do
        expect(User.search(nil, 1)).to eq([@mike, @philip, @stephens])
      end

      it 'paginates users' do
        expect(User.search(nil, 1, 1)).to eq([@mike])
        expect(User.search(nil, 2, 1)).to eq([@philip])
      end
    end

    context 'with search_term i' do
      it 'only finds mike and philip' do
        expect(User.search('i', 1, 10)).to eq([@mike, @philip])
      end

      it 'paginates users' do
        expect(User.search(nil, 1, 1)).to eq([@mike])
        expect(User.search(nil, 2, 1)).to eq([@philip])
      end
    end
  end
end
