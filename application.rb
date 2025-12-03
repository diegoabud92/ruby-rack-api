# frozen_string_literal: true

require 'cuba'
require 'dotenv/load'
require 'json'
require 'securerandom'

# Load models and controllers
require './app/models/base'
require './app/models/products'
require './app/controllers/base_controller'
require './app/controllers/products_controller'

# rubocop:disable Style/MutableConstant
TOKENS = {}
# rubocop:enable Style/MutableConstant

# Routes definition for the API using Cuba
Cuba.define do
  # GET /AUTHORS
  on 'AUTHORS' do
    on get do
      res.headers['Cache-Control'] = "public, max-age=#{60 * 60 * 24}"
      res.headers['Content-Type'] = 'text/plain'
      res.write File.read('AUTHORS')
    end
  end

  # POST /auth
  on 'auth' do
    on post do
      req.body.rewind
      datos = JSON.parse(req.body.read)
      if datos['username'] == ENV['USERNAME'] && datos['password'] == ENV['PASSWORD']
        token = SecureRandom.uuid
        TOKENS[token] = Time.now
        res.headers['Content-Type'] = 'application/json'
        res.write JSON.generate({ token: token })
      else
        res.status = 401
        res.headers['Content-Type'] = 'application/json'
        res.write JSON.generate({ error: 'Unauthorized' })
      end
    end
  end

  # GET /openapi.yaml
  on 'openapi.yaml' do
    on get do
      res.headers['Cache-Control'] = 'no-store'
      res.headers['Content-Type'] = 'text/yaml'
      res.write File.read('openapi.yaml')
    end
  end

  # Products routes
  on 'products' do
    # GET /products/last
    on get, 'last' do
      controller = ProductsController.new(req, res)
      controller.last(TOKENS)
    end

    # GET /products/:id
    on get, ':id' do |id|
      controller = ProductsController.new(req, res)
      controller.show(TOKENS, id: id)
    end

    # POST /products
    on post, root do
      controller = ProductsController.new(req, res)
      controller.create(TOKENS)
    end

    # GET /products
    on get, root do
      controller = ProductsController.new(req, res)
      controller.index(TOKENS)
    end
  end

  # TODO: Implement put and delete routes for products
end
