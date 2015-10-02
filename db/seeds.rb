# seed 2 admins
User.create!(
  name:  'Philip',
  email: 'philip@example.com',
  activated: true,
  admin: true,
  account_attributes: {
    password:              'coolkid',
    password_confirmation: 'coolkid'
  }
)
User.create!(
  name:  'Mike',
  email: 'mike@example.com',
  activated: true,
  admin:     true,
  account_attributes: {
    password:              'coolkid',
    password_confirmation: 'coolkid'
  }
)
User.create!(
  name:  'Stephens',
  email: 'stephens@example.com',
  activated: true,
  admin:     true,
  account_attributes: {
    password:              'coolkid',
    password_confirmation: 'coolkid'
  }
)
# seed 30 normal users
30.times do |i|
  User.create!(
    name:  Faker::Name.name,
    email: "User#{i}@example.com",
    activated: [true, false].sample,
    account_attributes: {
      password:              'foobar',
      password_confirmation: 'foobar'
    }
  )
end

# seed polls
me       = User.find_by(email: 'philip@example.com')
mike     = User.find_by(email: 'mike@example.com')
stephens = User.find_by(email: 'stephens@example.com')

me.polls.create!(content: 'Who will win Premier League this year?', choices_attributes: {
    '0' => { value: 'Arsenal' },
    '1' => { value: 'Chelsea' },
    '2' => { value: 'Manchester City'},
    '3' => { value: 'Manchester United'},
    '4' => { value: 'Liverpool'}
  }
)

mike.polls.create!(content: 'Is admin cool?', choices_attributes: {
    '0' => { value: 'yes' },
    '1' => { value: 'no' },
    '2' => { value: 'I dunno?'}
  }
)
stephens.polls.create(content: 'Are you going out tonight?', choices_attributes: {
    '0' => { value: 'yes' },
    '2' => { value: 'no' },
    '3' => { value: 'maybe' }
  }
)

User.where(activated: true).find_each do |user|
  Poll.find_each do |poll|
    poll.choices.sample.votes.create(voter: user)
  end
end

User.where(activated: true).take(20).each do |user|
  Poll.find_each do |poll|
    user.comments.create!(poll: poll, message: Faker::Lorem.sentence)
  end
end
