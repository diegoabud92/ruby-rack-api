# frozen_string_literal: true

require_relative './base_controller'

# Controller for handling authentication-related HTTP requests.
# Authenticates users and returns a JWT token.
class AuthController < BaseController
  def create
    payload = require_params(:username, :password)
    return unless payload

    user = User.find_by_username(payload['username'])
    return error_response('Credenciales inválidas', status: 401) unless user

    if BCrypt::Password.new(user.password) == payload['password']
      jwt_token = JwtAuth.encode({ user_id: user.id, username: user.username })
      json_response({ token: jwt_token })
    else
      error_response('Credenciales inválidas', status: 401)
    end
  end
end
