# frozen_string_literal: true

require_relative './base'

# Model for products
class Product < Base
  attr_accessor :id, :name

  def initialize(id: nil, name: nil)
    @id = id
    @name = name
  end

  def to_h
    { id: @id, name: @name }
  end

  def to_json(*args)
    to_h.to_json(*args)
  end
end
