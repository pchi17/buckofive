require 'rails_helper'

RSpec.describe Contact, type: :model do
  it { expect(subject).to validate_presence_of :sender_email }
  it { expect(subject).to validate_presence_of :message }

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

  it { expect(subject).to     allow_value(*valid_addresses).for(:sender_email) }
  it { expect(subject).to_not allow_value(*invalid_addresses).for(:sender_email) }
end
