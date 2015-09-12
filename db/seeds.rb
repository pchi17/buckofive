User.create!(
  name:  'Mike',
  email: 'mike@example.com',
  password:              'coolkid',
  password_confirmation: 'coolkid',
  activated: true,
  admin:     true
)

30.times do |i|
  User.create!(
    name:  Faker::Name.name,
    email: "User#{i}@example.com",
    password:              'foobar',
    password_confirmation: 'foobar',
    activated: [true, false].sample
  )
end
