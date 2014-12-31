require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'

module Gyngestol
  module Endpoint

    HTTP_METHODS = %w{head get put post delete}

    extend ActiveSupport::Concern
    include Escapes

    DEFAULT_STATUS_MESSAGES = {
      500 => 'Internal Server Error',
      200 => 'Ok',
      404 => 'Not Found'
    }

    CONTENT_TYPES = {
      :json => 'application/json'
    }

    def initialize(request)
      @request = request
      #@response = response
    end

    def request
      @request
    end

    def params
      request.params.dup.with_indifferent_access
    end

    def respond_with(format, text)
      throw :gyngestol_escape, ActionEscape.new(request, status_response(200, content_type: format, text: text))
    end

    def status_response(status, content_type: :json, text: DEFAULT_STATUS_MESSAGES[status])
      [status, {"Content-Type" => CONTENT_TYPES[content_type]}, [text]]
    end

  end#Endpoint
end
