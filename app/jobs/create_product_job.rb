# frozen_string_literal: true

require 'sidekiq'

# Job for creating a product
class CreateProductJob
  include Sidekiq::Job

  def perform(product_id, product_name)
    Product.new(id: product_id, name: product_name).save
  end
end
