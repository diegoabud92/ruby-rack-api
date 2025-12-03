# frozen_string_literal: true

require_relative './base_controller'

# Controller for handling product-related HTTP requests.
# Create and read operations for products through RESTful endpoints.
class ProductsController < BaseController
  # GET /products
  #
  def index(tokens)
    return unauthorized unless authorized?(tokens)

    products = Product.all
    @res.headers['Content-Type'] = 'application/json'
    @res.write JSON.generate(products.map(&:to_h))
  end

  # GET /products/:id
  #
  def show(tokens, id: nil)
    return unauthorized unless authorized?(tokens)

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

  # GET /products/last
  #
  def last(tokens)
    return unauthorized unless authorized?(tokens)

    product = Product.last_record
    @res.headers['Content-Type'] = 'application/json'
    if product
      @res.write JSON.generate(product.to_h)
    else
      @res.status = 404
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'No hay productos' })
    end
  end

  # POST /products
  #
  def create(tokens)
    return unauthorized unless authorized?(tokens)

    @req.body.rewind
    payload = JSON.parse(@req.body.read)
    unless payload['name']
      @res.status = 400
      @res.headers['Content-Type'] = 'application/json'
      @res.write JSON.generate({ error: 'Nombre del producto es obligatorio' })
      return
    end
    id = Product.next_available_id
    Thread.new do
      sleep 5
      product = Product.new(id: id, name: payload['name'])
      product.save
    end
    @res.status = 201
    @res.headers['Content-Type'] = 'application/json'
    @res.write JSON.generate({ message: 'Producto creado asincronamente, para obtener el producto use el endpoint GET /products/last' })
  end
end
