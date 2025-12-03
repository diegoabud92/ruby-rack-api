# frozen_string_literal: true

require 'rspec'
require 'rack/mock'
require 'json'

# Cargar la app
require_relative '../../application'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end

# Helper module para los tests
module SpecHelper
  def app
    Rack::Builder.new do
      use Rack::Deflater
      run Cuba
    end
  end

  def mock_request
    @mock_request ||= Rack::MockRequest.new(app)
  end

  # Helper para obtener un token válido
  def get_auth_token(username: ENV['USERNAME'], password: ENV['PASSWORD'])
    response = mock_request.post(
      '/auth',
      input: JSON.generate({ username: username, password: password }),
      'CONTENT_TYPE' => 'application/json'
    )
    JSON.parse(response.body)['token']
  end

  # Helper para hacer requests autenticados
  def auth_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  # Limpiar TOKENS entre tests
  def clear_tokens!
    TOKENS.clear
  end
end

RSpec.configure do |config|
  config.include SpecHelper
end
