class JsonWebToken
  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      if Rails.env == 'production'
        JWT.encode(payload, Rails.application.secret_key_base)
      else
        JWT.encode(payload, Rails.application.secrets.secret_key_base)
      end
    end

    def decode(token)
      body = if Rails.env == 'production'
               JWT.decode(token, Rails.application.secret_key_base)[0]
             else
               JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
             end
      HashWithIndifferentAccess.new body
    rescue StandardError
      nil
    end
  end
end
