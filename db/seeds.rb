# seed 2 admins
User.create!(
  name:  'Philip',
  email: 'philip@example.com',
  password:              'coolkid',
  password_confirmation: 'coolkid',
  activated: true,
  admin: true
)
User.create!(
  name:  'Mike',
  email: 'mike@example.com',
  password:              'coolkid',
  password_confirmation: 'coolkid',
  activated: true,
  admin:     true
)

# seed 30 normal users
30.times do |i|
  User.create!(
    name:  Faker::Name.name,
    email: "User#{i}@example.com",
    password:              'foobar',
    password_confirmation: 'foobar',
    activated: [true, false].sample
  )
end

# seed polls
me   = User.find_by(email: 'philip@example.com')
mike = User.find_by(email: 'mike@example.com')

me.polls.create!(content: 'Who will win Premier League this year?', choices_attributes: {
    '0' => { value: 'Arsenal' },
    '1' => { value: 'Chelsea' },
    '2' => { value: 'Manchester City'},
    '3' => { value: 'Manchester United'},
    '4' => { value: 'Liverpool'}
  }
)

mike.polls.create!(content: 'Will you drive a BMW?', choices_attributes: {
    '0' => { value: 'yes' },
    '1' => { value: 'no' },
    '2' => { value: 'I dunno?'}
  }
)

User.all.each do |user|
  Poll.all.each do |poll|
    poll.choices.sample.votes.create(user: user)
  end
end
