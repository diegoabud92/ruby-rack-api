# frozen_string_literal: true

# Encode and decode JWT tokens
module JwtAuth
  # JWT secret key
  SECRET_KEY = ENV['JWT_SECRET']

  # Encode a payload into a JWT token
  # @param payload [Hash] The payload to encode
  # @return [String] The encoded JWT token
  def self.encode(payload)
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
  end

  def self.valid_token?(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' })
    true
  rescue JWT::DecodeError
    false
  end
end
