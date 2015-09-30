FactoryGirl.define do
  factory :account do
    user
    password              'foobar'
    password_confirmation 'foobar'

    trait :activated do
      activated_at Time.now
    end
  end
end
