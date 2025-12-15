# frozen_string_literal: true

require_relative './base'

# Model for users
class User < Base
  attr_accessor :id, :username, :password

  def initialize(id: nil, username: nil, password: nil)
    @id = id
    @username = username
    @password = password
  end

  def self.find_by_username(username)
    all.find { |user| user.username == username }
  end

  def to_h
    { id: @id, username: @username }
  end
end
