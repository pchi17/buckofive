# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(
  name:  'Philip',
  email: 'philip@example.com',
  password:              'superfoobar',
  password_confirmation: 'superfoobar',
  admin:     true,
  activated: true
)
User.create!(
  name:  'Mike',
  email: 'mike@example.com',
  password:              'whatisthis?',
  password_confirmation: 'whatisthis?',
  activated: true
)
