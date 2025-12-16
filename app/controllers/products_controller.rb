# frozen_string_literal: true

require_relative './base_controller'

# Controller for handling product-related HTTP requests.
# Create and read operations for products through RESTful endpoints.
class ProductsController < BaseController
  # GET /products
  #
  def index
    return unauthorized unless authorized?

    products = Product.all
    json_response(products.map(&:to_h))
  end

  # GET /products/:id
  #
  def show(id: nil)
    return unauthorized unless authorized?

    product = Product.find(id)
    return error_response('Producto no encontrado', status: 404) unless product

    json_response(product.to_h)
  end

  # POST /products
  #
  def create
    return unauthorized unless authorized?

    payload = require_params(:name)
    return unless payload

    id = Product.next_available_id
    product = CreateProductJob.perform_in(5, id, payload['name'])
    return error_response('Error al crear el producto', status: 500) unless product

    json_response({ message: "Producto creado asincronamente, para visualizar el producto use el endpoint GET /products/#{id}" }, status: 201)
  end
end
