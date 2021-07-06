class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request
  
  attr_reader :command, :email, :password

  def authenticate
    @email = params[:email]
    @password = params[:password]
    @command = AuthenticateUser.call( @email, @password)

    if command.success?
      render json: authenticationResults
    else
      render json: { error: @command.errors }, status: :unauthorized
    end
  end

  private

  def invited_users_registered(user)
    invited_users = Array.new
    user.invited_users.each{|u| invited_users << {name: u.name, email: u.email}}
    invited_users
  end

  def authenticationResults
    user = User.find_by_email(@email)
    if user
      referral = user.referral.code if user.referral
      registrations = invited_users_registered(user)
      creditfromreferral = '$' + ((registrations.length / 5) * 10).to_s
      inviter = user.inviter
      invitername = inviter.name if inviter
      creditfromsignup = '$10' if inviter
    end
    { 
      auth_token: @command.result,
      username: user.name,
      invitername: invitername,
      referral: referral,
      invited_users: registrations,
      creditfromreferral: creditfromreferral,
      creditfromsignup: creditfromsignup
    }
  end
 
end
 