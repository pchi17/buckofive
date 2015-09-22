FactoryGirl.define do
  factory :choice do
    poll

    trait :yes do
      value 'yes'
    end

    trait :no do
      value 'no'
    end
  end
end
