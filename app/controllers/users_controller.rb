class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def create
    name = params['name']
    email = params['email']
    password = params['password']
    password_confirmation = params['password_confirmation']
    referral_code = params['referral_code'] || ''

    return unless valid_params(email, password, password_confirmation, referral_code)

    @user = User.new(
      name: name,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )
    if @user.save
      @user.inviter = @inviter unless @inviter.nil?
      command = AuthenticateUser.call(email, password)
      @auth_token = command.result
      render json: registration_results
    else
      render json: { error: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def valid_params(email, password, password_confirmation, referral_code)
    return false unless referral_code_comply(referral_code)
    return false if email_exists(email)
    return false unless password_confirmed(password, password_confirmation)

    true
  end

  def referral_code_comply(referral_code)
    return true if referral_code.empty?

    referral = Referral.find_by(code: referral_code)
    return false if invalid_referral(referral)

    @inviter = User.find(referral.user_id)
    return false if invalid_inviter(@inviter)

    true
  end

  # the referral code does not exist
  def invalid_referral(referral)
    if referral.nil?
      render json: { error: 'Invalid Referral Code' }
      return true
    end

    false
  end

  # in case the inviter has been removed from users
  def invalid_inviter(inviter)
    if inviter.nil?
      render json: { error: 'Invalid Referral Code' }
      return true
    end

    false
  end

  def email_exists(email)
    if User.find_by_email(email)
      render json: { error: 'email is already registered' }
      return true
    end

    false
  end

  def password_confirmed(password, password_confirm)
    if password != password_confirm
      render json: { error: 'password does not match password_confirmation' }
      return false
    end

    true
  end

  def registration_results
    invitername = @inviter.name if @inviter
    creditfromsignup = @inviter.nil? ? '$0' : '$10'

    {
      auth_token: @auth_token,
      username: @user.name,
      invitername: invitername,
      creditfromsignup: creditfromsignup
    }
  end
end
