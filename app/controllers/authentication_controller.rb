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
    user = User.find_by_email(params[:email])
    if user
      referral = user.referral.code if user.referral
      registrations = user.invited_users_list
      credit_from_referral = user.credit_from_referral
      inviter = user.inviter
      inviter_name = inviter.name if inviter
      credit_from_signup = '$10' if inviter
    end
    {
      auth_token: @command.result,
      user_name: user.name,
      inviter_name: inviter_name,
      referral: referral,
      invited_users: registrations,
      credit_from_referral: credit_from_referral,
      credit_from_signup: credit_from_signup
    }
  end
end
