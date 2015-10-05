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

FactoryGirl.define do
  factory :user, aliases: [:creator, :voter] do
    factory :philip do
      name 'Philip'
      email 'philip@example.com'
    end

    factory :mike do
      name  'Mike'
      email 'mike@example.com'
    end

    factory :stephens do
      name  'Stephens'
      email 'stephens@example.com'
    end

    trait :with_account do
      after(:build) { |user| build(:account, user: user) }
    end

    trait :admin do
      admin     true
      activated true
    end

    trait :activated do
      activated true
    end

    trait :invalid_email do
      email 'philip@invalid'
    end
  end
end
