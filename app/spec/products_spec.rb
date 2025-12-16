# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Products API' do
  let(:token) { get_auth_token }

  before(:each) do
    create_user
  end

  describe 'GET /products' do
    context 'with valid token' do
      it 'returns a list of products' do
        token = get_auth_token
        response = mock_request.get('/products', auth_header(token))

        expect(response.status).to eq(200)
        expect(response['Content-Type']).to eq('application/json')

        body = JSON.parse(response.body)
        expect(body).to be_an(Array)
      end
    end

    context 'without valid token' do
      it 'returns 401 Unauthorized' do
        response = mock_request.get('/products')

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'POST /products' do
    context 'with valid token and name' do
      it 'creates a product asynchronously' do
        allow(CreateProductJob).to receive(:perform_in) do |_delay, id, name|
          CreateProductJob.new.perform(id, name)
        end

        token = get_auth_token
        response = mock_request.post(
          '/products',
          input: JSON.generate({ name: 'Pizza Napolitana' }),
          'CONTENT_TYPE' => 'application/json',
          **auth_header(token)
        )
        expect(response.status).to eq(201)
        body = JSON.parse(response.body)
        match = body['message'].match(%r{GET /products/(\d+)})
        expect(match).not_to be_nil
        product_id = match[1]

        get_response = mock_request.get("/products/#{product_id}", auth_header(token))
        expect(get_response.status).to eq(200)

        product = JSON.parse(get_response.body)
        expect(product['id']).to eq(product_id.to_i)
        expect(product['name']).to eq('Pizza Napolitana')
      end
    end

    context 'without name' do
      it 'returns 400 Bad Request' do
        token = get_auth_token
        response = mock_request.post(
          '/products',
          input: JSON.generate({}),
          'CONTENT_TYPE' => 'application/json',
          **auth_header(token)
        )

        expect(response.status).to eq(400)

        body = JSON.parse(response.body)
        expect(body['error']).to eq('Campos requeridos: name')
      end
    end

    context 'without token' do
      it 'returns 401 Unauthorized' do
        response = mock_request.post(
          '/products',
          'input' => JSON.generate({ name: 'Test' }),
          'CONTENT_TYPE' => 'application/json'
        )

        expect(response.status).to eq(401)
      end
    end
  end

  describe 'GET /products/:id' do
    context 'when product does not exist' do
      it 'returns 404 Not Found' do
        token = get_auth_token
        response = mock_request.get('/products/99999', auth_header(token))

        expect(response.status).to eq(404)

        body = JSON.parse(response.body)
        expect(body['error']).to eq('Producto no encontrado')
      end
    end
  end

  describe 'GET /products/last' do
    context 'when there are no products' do
      it 'returns 404 or the last product' do
        token = get_auth_token
        response = mock_request.get('/products/last', auth_header(token))

        # Puede ser 200 con producto o 404 si no hay productos
        expect([200, 404]).to include(response.status)
      end
    end
  end

  describe 'gzip compression' do
    context 'when client requests gzip encoding' do
      it 'returns gzip compressed response' do
        token = get_auth_token
        response = mock_request.get(
          '/products',
          'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
          **auth_header(token)
        )

        expect(response.status).to eq(200)
        expect(response['Content-Encoding']).to eq('gzip')
        expect(response['Vary']).to eq('Accept-Encoding')
      end
    end

    context 'when client does not request gzip encoding' do
      it 'returns uncompressed response' do
        token = get_auth_token
        response = mock_request.get('/products', auth_header(token))

        expect(response.status).to eq(200)
        expect(response['Content-Encoding']).to be_nil
      end
    end
  end
end
