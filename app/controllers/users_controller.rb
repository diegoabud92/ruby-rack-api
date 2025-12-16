# frozen_string_literal: true

require_relative './base_controller'
require 'bcrypt'

# Controller for creating users.
class UsersController < BaseController
  # POST /users
  #
  def create
    payload = require_params(:username, :password)
    return unless payload

    id = User.next_available_id
    hashed_password = BCrypt::Password.create(payload['password'])
    user = User.new(id: id, username: payload['username'], password: hashed_password)
    user.save
    json_response({ message: "Usuario creado correctamente, id: #{id}, username: #{payload['username']}" }, status: 201)
  end
end
