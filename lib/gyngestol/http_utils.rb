module Gyngestol
  module HttpUtils
    REQUEST_METHODS = %w{head get put post delete}

    DEFAULT_STATUS_MESSAGES = {
      500 => 'Internal Server Error',
      200 => 'Ok',
      404 => 'Not Found'
    }

    CONTENT_TYPES = {
      :json => 'application/json'
    }

  end
end
