FactoryGirl.define do
  factory :user do
    password              'foobar'
    password_confirmation 'foobar'

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

    trait :admin do
      admin     true
      # admin should be activated I hope...
      activated true
      activated_at Time.now
    end

    trait :activated do
      activated true
      activated_at Time.now
    end

    trait :invalid_email do
      email 'philip@invalid'
    end
  end
end
