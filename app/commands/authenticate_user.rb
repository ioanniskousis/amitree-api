class AuthenticateUser
  prepend SimpleCommand

  attr_reader :user

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :email, :password

  def user
    $current_user = User.find_by_email(email)
    # $current_user = @user
    # return user if user&.authenticate(password)
    return $current_user if $current_user && $current_user.authenticate(password)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
