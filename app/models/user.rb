class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, length: { minimum: 4 }
  validates :password, presence: true, length: { minimum: 4 }
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

  # points to referrals table. added when user creates a new referral code
  has_one :referral, dependent: :destroy

  # points to referenced_registrations table
  has_many :referenced_registrations, foreign_key: 'referer_id', dependent: :destroy
  has_many :invited_users, class_name: 'User', through: :referenced_registrations, source: :user

  #points to referenced_registrations that still do not have been checked to count for credit
  has_many :unchecked_referenced_registrations, -> { unchecked }, class_name: 'ReferencedRegistration', foreign_key: 'referer_id'

  # added when registers as a new user with referral code
  has_one :inverse_referenced_registration,
          class_name: 'ReferencedRegistration',
          foreign_key: 'user_id',
          dependent: :destroy

  has_one :inviter,
          class_name: 'User',
          through: :inverse_referenced_registration,
          foreign_key: 'referer_id',
          source: :referer

  has_one :credit

  def invited_users_list
    users = []
    invited_users.each { |u| users << { name: u.name, email: u.email } }
    users
  end

  def credit_from_referral
    "$#{(invited_users.length / 5) * 10}"
  end

  def update_referenced_registrations
    if referenced_registrations.count > 4

    end
  end
end
