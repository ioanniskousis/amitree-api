require 'rails_helper'

describe Credit, type: :request do
  it 'Successful registration of user with referral code and confirms user\'s credit $10' do
    referral_code = '12345678901234567890'
    User.create!(name: 'John', email: 'example@gmail.com', password: 'example')
    Referral.create(code: referral_code, user_id: User.first.id)

    post '/register', params: {
      name: 'Paul',
      email: 'paul@gmail.com',
      password: 'paul',
      password_confirmation: 'paul',
      referral_code: referral_code
    }

    user = User.last
    expect(user.credit.amount).to eq(10.0)
  end

  it 'Credits inviter user with $20 for 10 invited users' do
    User.create(name: 'John', email: 'example@gmail.com', password: 'example')

    post '/authenticate', params: { email: 'example@gmail.com', password: 'example' }
    auth_token = JSON.parse(response.body)['auth_token']
    user_id = JSON.parse(response.body)['user_id']

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

    get "/user/#{user_id}", headers: { Authorization: "Bearer #{auth_token}" }
    expect(JSON.parse(response.body)['credit']).to eq(20.0)
  end
end
