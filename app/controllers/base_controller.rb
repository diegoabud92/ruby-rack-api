# frozen_string_literal: true

# Base controller for all controllers
class BaseController
  def initialize(req, res)
    @req = req
    @res = res
  end

  def authorized?(tokens)
    token = @req.env['HTTP_AUTHORIZATION']
    return false unless token

    token = token.sub(/^Bearer /, '')
    tokens.key?(token)
  end

  def unauthorized
    @res.status = 401
    @res.headers['Content-Type'] = 'text/plain'
    @res.write 'Unauthorized'
  end
end
