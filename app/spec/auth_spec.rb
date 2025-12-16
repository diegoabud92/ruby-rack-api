# frozen_string_literal: true

require 'bcrypt'
require_relative 'spec_helper'

RSpec.describe 'Auth API' do
  before(:each) do
    create_user
  end

  describe 'POST /auth' do
    context 'with valid credentials' do
      it 'returns a token' do
        response = mock_request.post(
          '/auth',
          input: JSON.generate({ username: 'admin', password: 'fudo' }),
          'CONTENT_TYPE' => 'application/json'
        )

        expect(response.status).to eq(200)
        expect(response['Content-Type']).to eq('application/json')

        body = JSON.parse(response.body)
        expect(body).to have_key('token')
      end
    end

    context 'with invalid credentials' do
      it 'returns 401 Unauthorized' do
        response = mock_request.post(
          '/auth',
          input: JSON.generate({ username: 'pepito', password: 'perez' }),
          'CONTENT_TYPE' => 'application/json'
        )

        expect(response.status).to eq(401)
        expect(response['Content-Type']).to eq('application/json')

        body = JSON.parse(response.body)
        expect(body['error']).to eq('Unauthorized')
      end
    end

    context 'with missing credentials' do
      it 'returns 401 Unauthorized' do
        response = mock_request.post(
          '/auth',
          input: JSON.generate({}),
          'CONTENT_TYPE' => 'application/json'
        )

        expect(response.status).to eq(400)
      end
    end
  end
end
