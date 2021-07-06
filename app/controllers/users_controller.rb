class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def create
    name = params['name']
    email = params['email']
    password = params['password']
    password_confirmation = params['password_confirmation']
    referral_code = params['referral_code'] || ''
    
    unless referral_code.size == 0
      referral = Referral.find_by(code: referral_code)
      return if invalid_referral(referral)
      @inviter = User.find(referral.user_id)
      return if invalid_inviter(@inviter)
    end

    return if email_exists(email)
    return unless password_confirmed(password, password_confirmation)

    @user = User.new(
      name: name,
      email: email,
      password: password,
      password_confirmation: password_confirmation
    )

    if @user.save
      @user.inviter = @inviter unless @inviter.nil?
      command = AuthenticateUser.call( email, password)
      @auth_token = command.result
      render json: registrationResults
    else
      render json: { error: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def email_exists(e)
    user = User.find_by_email(e)
    if user
      render json: { error: "email is already registered" }
      return true
    end
    false
  end

  def password_confirmed(p, pc)
    if p != pc
      render json: { error: "password does not match password_confirmation" }
      return false
    end
    true
  end

  # the referral code does not exist
  def invalid_referral(referral)
    render json: { error: "Invalid Referral Code" } if referral.nil?
    return true if referral.nil?
    false
  end

  # in case the inviter has been removed from users
  def invalid_inviter(inviter)
    render json: { error: "Invalid Referral Code" } if inviter.nil?
    return true if inviter.nil?
    false
  end

  def registrationResults
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
