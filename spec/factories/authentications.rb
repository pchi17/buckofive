FactoryGirl.define do
  factory :authentication do
    user
    provider 'twitter'
    uid      '1234'
    token    'abcdefg'
    secret   '1234567'
  end
end
