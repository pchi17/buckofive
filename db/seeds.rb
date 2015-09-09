User.create!(
  name:  'Philip',
  email: 'philip@example.com',
  password:              'foobar',
  password_confirmation: 'foobar',
  admin:     true,
  activated: true
)
User.create!(
  name:  'Mike',
  email: 'mike@example.com',
  password:              'coolkid',
  password_confirmation: 'coolkid',
  activated: true
)

me = User.find_by(email: 'philip@example.com')
me.authentications.create!(
  provider: 'twitter',
  uid:      '1234',
  token:    'abcdefg',
  secret:   '1234567'
)
