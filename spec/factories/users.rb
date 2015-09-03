FactoryGirl.define do
  factory :user do
    name  'Philip'
    email 'philip@example.com'
    password              'foobar'
    password_confirmation 'foobar'

    trait :another_user do
      name  'Mike'
      email 'mike@example.com'
      password              'coolkid'
      password_confirmation 'coolkid'
    end

    trait :admin do
      name  'Super Admin'
      email 'admin@example.com'
      password              'admin1'
      password_confirmation 'admin1'
      admin true
    end

    trait :invalid_email do
      email 'philip@invalid'
    end
  end
end
