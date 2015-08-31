FactoryGirl.define do
  factory :user do
    name  'Pengfei Philip Chi'
    email 'philip@example.com'
    password              'password'
    password_confirmation 'password'

    trait :invalid_email do
      email 'philip@invalid'
    end
  end
end
