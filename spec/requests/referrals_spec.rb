require 'rails_helper'


describe 'Referral Creation', type: :request do

  it 'Successfully creates referral code' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')
    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']

    post '/referral', headers: {'Authorization': 'Bearer ' + auth_token}

    referral_code = JSON.parse(response.body)['referral_code']

    expect(referral_code.length).to eq(20)
  end

  it 'Unsuccessful referral code creation by unauthorized user' do
 
    post '/referral', headers: {'Authorization': 'Bearer ' + 'auth_token'}

    expect(JSON.parse(response.body)['error']).to eq('Not Authorized')

  end

  it 'Credits inviter user with $20 for 10 invited users' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')
    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']
    post '/referral', headers: {'Authorization': 'Bearer ' + auth_token}
    referral_code = JSON.parse(response.body)['referral_code']

    post '/register', params: {name: 'user0', email: 'user0@gmail.com', password: 'user0', password_confirmation: 'user0', referral_code: referral_code}
    post '/register', params: {name: 'user1', email: 'user1@gmail.com', password: 'user1', password_confirmation: 'user1', referral_code: referral_code}
    post '/register', params: {name: 'user2', email: 'user2@gmail.com', password: 'user2', password_confirmation: 'user2', referral_code: referral_code}
    post '/register', params: {name: 'user3', email: 'user3@gmail.com', password: 'user3', password_confirmation: 'user3', referral_code: referral_code}
    post '/register', params: {name: 'user4', email: 'user4@gmail.com', password: 'user4', password_confirmation: 'user4', referral_code: referral_code}
    post '/register', params: {name: 'user5', email: 'user5@gmail.com', password: 'user5', password_confirmation: 'user5', referral_code: referral_code}
    post '/register', params: {name: 'user6', email: 'user6@gmail.com', password: 'user6', password_confirmation: 'user6', referral_code: referral_code}
    post '/register', params: {name: 'user7', email: 'user7@gmail.com', password: 'user7', password_confirmation: 'user7', referral_code: referral_code}
    post '/register', params: {name: 'user8', email: 'user8@gmail.com', password: 'user8', password_confirmation: 'user8', referral_code: referral_code}
    post '/register', params: {name: 'user9', email: 'user9@gmail.com', password: 'user9', password_confirmation: 'user9', referral_code: referral_code}


    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    expect(JSON.parse(response.body)['creditfromreferral']).to eq('$20')
  end
end
