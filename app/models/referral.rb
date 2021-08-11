class Referral < ApplicationRecord
  # links users with their referral code

  belongs_to :user
end
