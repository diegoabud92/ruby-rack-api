# frozen_string_literal: true

require 'cuba'
require 'dotenv/load'
require 'json'
require 'jwt'
require 'sidekiq'

# Load models and controllers
require './app/jobs/create_product_job'
require './app/lib/jwt_auth'
require './app/models/base'
require './app/models/products'
require './app/models/users'
require './app/controllers/base_controller'
require './app/controllers/products_controller'
require './app/controllers/users_controller'
require './app/controllers/auth_controller'

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
      controller = AuthController.new(req, res)
      controller.create
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
    # GET /products/:id
    on get, ':id' do |id|
      controller = ProductsController.new(req, res)
      controller.show(id: id)
    end

    # POST /products
    on post, root do
      controller = ProductsController.new(req, res)
      controller.create
    end

    # GET /products
    on get, root do
      controller = ProductsController.new(req, res)
      controller.index
    end
  end

  # Users routes
  on 'users' do
    # POST /users
    on post, root do
      controller = UsersController.new(req, res)
      controller.create
    end
  end

  # 404 Not Found - si ninguna ruta matcheó
  on default do
    error_response('Not Found', status: 404)
  end

  # TODO: Implement put and delete routes for products
end
