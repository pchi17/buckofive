FactoryGirl.define do
  factory :user do
    name  'Pengfei Philip Chi'
    email 'philip@buckofive.com'
    password              'password'
    password_confirmation 'password'

    trait :another_user do
      name  'Mike'
      email 'mike@buckofive.com'
      password              'coolkid'
      password_confirmation 'coolkid'
    end

    trait :admin do
      name  'Super Admin'
      email 'admin@buckofive.com'
      password              'admin1'
      password_confirmation 'admin1'
      admin true
    end

    trait :invalid_email do
      email 'philip@invalid'
    end
  end
end
