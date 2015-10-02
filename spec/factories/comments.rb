FactoryGirl.define do
  factory :comment do
    user
    poll
    message 'this is a nice poll'
  end
end
