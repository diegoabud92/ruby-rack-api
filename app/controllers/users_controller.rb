# frozen_string_literal: true

require_relative './base_controller'
require 'bcrypt'

# Controller for creating users.
class UsersController < BaseController
  # POST /users
  #
  def create
    @req.body.rewind
    payload = JSON.parse(@req.body.read)
    unless payload['username'] && payload['password']
      @res.status = 400
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'Username y password son obligatorios' })
      return
    end
    id = User.next_available_id
    hashed_password = BCrypt::Password.create(payload['password'])
    Thread.new do
      sleep 5
      user = User.new(id: id, username: payload['username'], password: hashed_password)
      user.save
    end
    @res.status = 201
    @res.headers['Content-Type'] = 'application/json'
    @res.write JSON.generate({ message: "Usuario creado asincrono correctamente, id: #{id}, username: #{payload['username']}" })
  end
end
