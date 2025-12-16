# frozen_string_literal: true

# Base controller for all controllers
class BaseController
  def initialize(req, res)
    @req = req
    @res = res
  end

  def authorized?
    token = extract_token
    return false unless token

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

  def json_body
    @req.body.rewind
    JSON.parse(@req.body.read)
  end

  def json_response(data, status: 200)
    @res.status = status
    @res.headers['Content-Type'] = 'application/json'
    @res.write JSON.generate(data)
  end

  def error_response(message, status: 400)
    json_response({ error: message }, status: status)
  end

  # Valida que los parámetros requeridos estén presentes
  # Retorna el payload si todos están presentes, nil si falta alguno
  def require_params(*keys)
    payload = json_body
    missing = keys.select { |k| payload[k.to_s].nil? || payload[k.to_s].to_s.strip.empty? }

    if missing.any?
      error_response("Campos requeridos: #{missing.join(', ')}")
      return nil
    end

    payload
  end

  private

  def extract_token
    token = @req.env['HTTP_AUTHORIZATION']
    return nil unless token

    token.sub(/^Bearer /, '')
  end
end
