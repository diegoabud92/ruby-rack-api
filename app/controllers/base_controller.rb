# frozen_string_literal: true

# Base controller for all controllers
class BaseController
  def initialize(req, res)
    @req = req
    @res = res
  end

  def authorized?
    token = @req.env['HTTP_AUTHORIZATION']
    return false unless token

    token = token.sub(/^Bearer /, '')
    JwtAuth.valid_token?(token)
  end

  def current_user_id
    token = extract_token
    return nil unless token

    decoded_token = JwtAuth.decode(token)
    decoded_token['user_id']
  end

  def unauthorized
    @res.status = 401
    @res.headers['Content-Type'] = 'text/plain'
    @res.write 'Unauthorized'
  end

  private

  def extract_token
    token = @req.env['HTTP_AUTHORIZATION']
    return nil unless token

    token.sub(/^Bearer /, '')
  end
end
