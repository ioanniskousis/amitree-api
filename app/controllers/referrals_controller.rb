class ReferralsController < ApplicationController
  def create
    return if user_has_referral_code

    referral_code = generate_code
    @current_user.create_referral(code: referral_code)
    render json: { referral_code: referral_code }
  end

  private

  def user_has_referral_code
    if Referral.where(user_id: @current_user.id).exists?
      render json: {constrain: 'You Already Have Created A Referral Code'}
      return true 
    end
    false
  end

  def generate_code
    loop do
      code = SecureRandom.hex(10)

      break code unless Referral.where(code: code).exists?
    end
  end

end