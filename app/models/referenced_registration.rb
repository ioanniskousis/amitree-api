class ReferencedRegistration < ApplicationRecord
  # when a new user registers using a referral code
  # then 
  # a record is created to link the inviter user (the creator of the refarral code) with the new user

  belongs_to :user
  belongs_to :referer, class_name: 'User', foreign_key: 'referer_id'

end
