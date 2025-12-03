# frozen_string_literal: true

require './application'

use Rack::Deflater
use Rack::Reloader, 0
run Cuba
