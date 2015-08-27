FactoryGirl.define do
  factory :user do
    name "MyString"
    email "MyString"
    admin false
    activated false
    password_digest "MyString"
    remember_digest "MyString"
    activation_digest "MyString"
    reset_digest "MyString"
    activated_at  "2015-08-26 20:50:28"
    reset_sent_at "2015-08-26 20:50:28"
  end
end
