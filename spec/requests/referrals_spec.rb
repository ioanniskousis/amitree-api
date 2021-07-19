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
end
