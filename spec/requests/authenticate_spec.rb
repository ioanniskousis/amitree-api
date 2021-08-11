require 'rails_helper'

describe 'User Authentication', type: :request do
  it 'Successful Authentication returns token' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')

    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']

    expect(auth_token).not_to eq(nil)
  end

  it 'Authentication with Invalid credentials returns no token' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')

    post '/authenticate', params: { email: 'example@gmail.com', password: 'example1' }
    auth_token = JSON.parse(response.body)['auth_token']

    expect(auth_token).to eq(nil)
  end

  it 'Authentication with Invalid credentials returns error message' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')

    post '/authenticate', params: { email: 'example@gmail.com', password: 'example1' }

    expect(JSON.parse(response.body)['error']['user_authentication']).to eq('invalid credentials')
  end
end
