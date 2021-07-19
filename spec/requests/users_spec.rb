require 'rails_helper'

describe 'User Registration', type: :request do
  it 'Successful registration of user without referral code' do
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'paul' }

    user = User.first
    expect(user.name).to eq('Paul')
  end

  it 'Invalid registration with name too short' do
    post '/register', params: { name: 'Pau', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'paul' }

    expect(JSON.parse(response.body)['error']['name'][0]).to eq('is too short (minimum is 4 characters)')
  end

  it 'Invalid registration with name blank' do
    post '/register', params: { name: '', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'paul' }

    expect(JSON.parse(response.body)['error']['name'][0]).to eq('can\'t be blank')
  end

  it 'Invalid registration with email blank' do
    post '/register', params: { name: 'Paul', email: '', password: 'paul', password_confirmation: 'paul' }

    expect(JSON.parse(response.body)['error']['email'][0]).to eq('is invalid')
  end

  it 'Invalid registration with invalid email' do
    post '/register', params: { name: 'Paul', email: 'qeqweqweqwewq', password: 'paul', password_confirmation: 'paul' }

    expect(JSON.parse(response.body)['error']['email'][0]).to eq('is invalid')
  end

  it 'Invalid registration with email already registered' do
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'paul' }
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'paul' }

    expect(JSON.parse(response.body)['error']).to eq('email is already registered')
  end

  it 'Invalid registration with password blank' do
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: '', password_confirmation: '' }

    expect(JSON.parse(response.body)['error']['password'][0]).to eq('can\'t be blank')
  end

  it 'Invalid registration with password too short' do
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: '123', password_confirmation: '123' }

    expect(JSON.parse(response.body)['error']['password'][0]).to eq('is too short (minimum is 4 characters)')
  end

  it 'Invalid registration with wrong password confirmation' do
    post '/register', params: { name: 'Paul', email: 'paul@gmail.com', password: 'paul', password_confirmation: 'p' }

    expect(JSON.parse(response.body)['error']).to eq('password does not match password_confirmation')
  end

  it 'Successful registration of user with referral code and confirms user\'s name' do
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
    expect(user.name).to eq('Paul')
  end

  it 'Successful registration of user with referral code and confirms inviter\'s name' do
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
    inviter = User.find(user.inverse_referenced_registration.referer_id)

    expect(inviter.name).to eq('John')
  end

  it 'Successful registration of user with referral code and confirms credit of $10' do
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

    expect(User.last.credit.amount).to eq(10.0)
  end

  it 'Blocks registration of user with invalid referral code' do
    referral_code = '12345678901234567890'
    User.create!(name: 'John', email: 'example@gmail.com', password: 'example')
    Referral.create(code: referral_code, user_id: User.first.id)

    post '/register', params: {
      name: 'Paul',
      email: 'paul@gmail.com',
      password: 'paul',
      password_confirmation: 'paul',
      referral_code: 'invalid-referral-code'
    }

    expect(JSON.parse(response.body)['error']).to eq('Invalid Referral Code')
  end
end
