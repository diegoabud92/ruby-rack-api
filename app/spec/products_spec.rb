# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe 'Products API' do
  let(:token) { get_auth_token }

  before(:each) do
    clear_tokens!
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
        token = get_auth_token
        response = mock_request.post(
          '/products',
          input: JSON.generate({ name: 'Pizza Napolitana' }),
          'CONTENT_TYPE' => 'application/json',
          **auth_header(token)
        )
        expect(response.status).to eq(201)
        expect(response['Content-Type']).to eq('application/json')

        body = JSON.parse(response.body)
        expect(body['message']).to eq('Producto creado asincronamente, para obtener el producto use el endpoint GET /products/last')
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
        expect(body['error']).to eq('Nombre del producto es obligatorio')
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
end
