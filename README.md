# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



<hr/>

create the project with command
```
rails new amitree-api --api --database=postgresql -T
```
- the --api flag configures the project for API implementation
- the --database=postgresql flag configures a postgresql database as defaulte
- the -T skips the creation of test. We'll configure rspec for test units

<hr/>

- add gems for db

```
group :development, :test do
  gem 'sqlite3', '~> 1.4'
end
group :production do
  gem 'pg', '~> 1.1'
end
```

- configure database.yml for default db per environment
```
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  timeout: 5000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  adapter: postgresql
  encoding: unicode
  database: ami_api_production
  username: ami_api
  password: <%= ENV['AMI_API_DATABASE_PASSWORD'] %>

```

- add gem for encription
```
gem 'bcrypt', '~> 3.1.7'
```

- created uers with
```
rails g model User name email password_digest
```
<hr/>

migrate
```
class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

    end
    add_index :users, :email,  unique: true
  end
end
```

- added has_secure_password .. so the password is properly encrypted into the database
```
class User < ApplicationRecord
  has_secure_password
end
```

<hr/>

- added JsonWebToken

```
- gem 'jwt' 
```
to implement token generation using lib/json_web_token.rb
```
class JsonWebToken
 class << self
   def encode(payload, exp = 24.hours.from_now)
     payload[:exp] = exp.to_i
     JWT.encode(payload, Rails.application.secrets.secret_key_base)
   end

   def decode(token)
     body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
     HashWithIndifferentAccess.new body
   rescue
     nil
   end
 end
end

```

<hr/>

configure config/application.rb to pre-load lib files

```
config.autoload_paths << Rails.root.join('lib')
```
<hr/>

- added simplecommand

```
gem 'simple_command'
```

- and create commands
  
<hr/>

- add command files
- for Authenticating Users
  
  app/commands/authenticate_user.rb

- for Checking User Authorization
  
  app/commands/authorize_api_request.rb
<hr/>

- in 

```
class ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  end

end
```

- create Referral model
```
rails g model Referral code:string user:references

create_table :referrals do |t|
  t.string :code, null: false, index: { unique: true }
  t.references :user, null: false, index: { unique: true }

end
```
