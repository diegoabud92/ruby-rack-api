# frozen_string_literal: true

require 'rspec'
require 'rack/mock'
require 'json'

# Cargar la app
require_relative '../../application'

RSpec.configure do |config|
  config.before(:suite) do
    File.delete('db.pstore') if File.exist?('db.pstore')
  end

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

  def create_user(username: 'admin', password: 'fudo')
    return if User.find_by_username(username)

    id = User.next_available_id
    hashed_password = BCrypt::Password.create(password)
    user = User.new(id: id, username: username, password: hashed_password)
    user.save
  end

  def mock_request
    @mock_request ||= Rack::MockRequest.new(app)
  end

  def get_auth_token(username: 'admin', password: 'fudo')
    response = mock_request.post(
      '/auth',
      input: JSON.generate({ username: username, password: password }),
      'CONTENT_TYPE' => 'application/json'
    )
    JSON.parse(response.body)['token']
  end

  def auth_header(token)
    { 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include SpecHelper
end
