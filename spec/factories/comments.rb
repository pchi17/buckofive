FactoryGirl.define do
  factory :comment do
    user
    poll
    content 'this is a nice poll'
  end
end
