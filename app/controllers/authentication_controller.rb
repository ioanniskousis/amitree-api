class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    @command = AuthenticateUser.call(params[:email], params[:password])

    if @command.success?
      render json: authentication_results
    else
      render json: { error: @command.errors }, status: :unauthorized
    end
  end

  private

  def authentication_results
    user = $current_user
    referral = user.referral.code if user.referral
    registrations = user.invited_users_list
    creditfromreferral = user.credit_from_referral
    inviter = user.inviter
    invitername = inviter.name if inviter
    creditfromsignup = '$10' if inviter

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
