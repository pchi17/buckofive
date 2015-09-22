FactoryGirl.define do
  factory :poll do
    user
    content "What can be better?"

    after(:build) do |poll|
      choices_attributes = []
      choices_attributes << attributes_for(:choice, :yes)
      choices_attributes << attributes_for(:choice, :no)
      poll.choices_attributes = choices_attributes
    end
  end
end
