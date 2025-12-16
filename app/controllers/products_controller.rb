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
    @res.headers['Content-Type'] = 'application/json'
    @res.write JSON.generate(products.map(&:to_h))
  end

  # GET /products/:id
  #
  def show(id: nil)
    return unauthorized unless authorized?

    product = Product.find(id)
    @res.headers['Content-Type'] = 'application/json'
    if product
      @res.write JSON.generate(product.to_h)
    else
      @res.status = 404
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'Producto no encontrado' })
    end
  end

  # POST /products
  #
  def create
    return unauthorized unless authorized?

    @req.body.rewind
    payload = JSON.parse(@req.body.read)
    unless payload['name']
      @res.status = 400
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'Nombre del producto es obligatorio' })
      return
    end
    id = Product.next_available_id
    product = CreateProductJob.perform_in(5, id, payload['name'])
    if product
      @res.status = 201
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ message: "Producto creado asincronamente, para visualizar el producto use el endpoint GET /products/#{id}" })
    else
      @res.status = 500
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'Error al crear el producto' })
    end
  end
end
