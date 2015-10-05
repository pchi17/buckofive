<a href="https://buckofive.herokuapp.com" target="_blank">Buck O Five</a>
===========

An app designed to make voting easy and fun

# How to run buckofive from your local machine #

## Install  

* Fork this repository
* Clone this repository into desired directory, i.e. `desktop/buckofive`

  change into project root directory `cd desktop/buckofive`

	run `bundle install [--without production]`

## environments and third party resources you need

### .env.json file

* You need a `.env.json` file under root directory to hold the environment variables.
* Inside desktop/buckofive run `cp .example.env.json .env.json`
* DOUBLE CHECK '.env.json' is in `.gitignore`, if you plan to open source your project.

### Database

* You need postgresql database on your local machine

	<code>brew update</code>

	<code>brew install postgresql</code>

	see <a href="http://www.postgresql.org/docs/9.4/static/index.html" target="_blank">postgresql documentation for more details on installation</a>


### Twitter signup and login

* Users of this app may use Twitter to signup and login
* visit <a href="https://apps.twitter.com/">Twitter developer site</a> to create a new app
* under settings enter `http://127.0.0.1:3000/auth/twitter/callback` for "Callback URL"
* copy "Consumer Key" into "TWITTER_API_KEY" in `.env.json`
* copy "Consumer Secret" into "TWITTER_API_SECRET" `.env.json`

### Amazon AWS S3

* This app uses <a href="http://aws.amazon.com/" target="_blank">Amazon S3</a> for photo storage. So you need to sign up for AWS.
* Create a user via <a href="http://aws.amazon.com/iam/" target="_blank">AWS Identity and Access Management (IAM)</a>
* Grant the created user administrator privileges
* copy the created user's access key and secret key into AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in `.env.json`
* create a bucket using AWS Console and copy the bucket name into `.env.json`


### carrierwave

* This app uses <a href="https://github.com/carrierwaveuploader/carrierwave" target="_blank">carrierwave</a> for photo processing.
* add `gem 'carrierwave'` to `Gemfile` and run `bundle install [--without production]`

* CarrierWave uses ImagMagick to do photo processing
* `brew install imagemagick`


### Sidekiq

* This app uses <a href="https://github.com/mperham/sidekiq" target="_blank">sidekiq</a> for background processing of email and photos.
* add `gem 'sidekiq'` to `Gemfile` and run `bundle install [--without production]`

### Redis

* Sidekiq uses Redis for data storage, to install Redis on your computer
* Run `brew install redis`

### Mandrill for email

* This app uses <a href="https://www.mandrill.com/" target="_blank">Mandrill</a> for email server.
* Register a free account your USER_NAME will likely be your email and your PASSWORD will likely be an API key you generate through Mandrill.
* copy those values into `.env.json`

## Running app locally

* Set up development and testing databases by running `bundle exec rake db:migrate:reset`
* In new terminal run `redis-server`
* In new terminal run `rails server`
* In new terminal run `bundle exec sidekiq -C config/sidekiq.yml` to start sidekiq
* You can also user foreman to start both rails server and sidekiq, to use foreman,
* Run `gem install foreman` and then `foreman start`.
* DO NOT add `foreman` to `Gemfile`
* In new terminal run `bundle exec guard` to have guard watch for changes that need to be tested.
