require 'rails_helper'

describe 'Referral Creation', type: :request do
  it 'Successfully creates referral code' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')
    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']

    post '/referral', headers: { Authorization: "Bearer #{auth_token}" }

    referral_code = JSON.parse(response.body)['referral_code']

    expect(referral_code.length).to eq(20)
  end

  it 'Unsuccessful referral code creation by unauthorized user' do
    post '/referral', headers: {}

    expect(JSON.parse(response.body)['error']).to eq('Not Authorized')
  end

  it 'Credits inviter user with $20 for 10 invited users' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')
    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']
    post '/referral', headers: { Authorization: "Bearer #{auth_token}" }
    referral_code = JSON.parse(response.body)['referral_code']

    names = %w[user0 user1 user2 user3 user4 user5 user6 user7 user8 user9]
    names.each do |n|
      post '/register', params: {
        name: n,
        email: "#{n}@gmail.com",
        password: n,
        password_confirmation: n,
        referral_code: referral_code
      }
    end

    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    expect(JSON.parse(response.body)['credit_from_referral']).to eq('$20')
  end
end
