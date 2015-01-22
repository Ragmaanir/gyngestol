require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'

module Gyngestol
  module Endpoint

    extend ActiveSupport::Concern
    include Escapes

    def initialize(gyngestol, request)
      @_gyngestol = gyngestol
      @_request = request
      #@response = response
    end

  protected

    def gyngestol
      @_gyngestol
    end

    def request
      @_request
    end

    def params
      request.params.dup.with_indifferent_access
    end

    def respond_with(format, text)
      response = status_response(200, content_type: format, text: text)
      escape_action_with!(ActionEscape.new(request, response))
    end

    def status_response(status, content_type: _default_response_type, text: HttpUtils::DEFAULT_STATUS_MESSAGES[status])
      [status, {"Content-Type" => HttpUtils::CONTENT_TYPES[content_type]}, [text]]
    end

    def redirect_to(url, type=:temporary)
      resp = Rack::Response.new
      resp.redirect(url)
      resp
    end

    def escape_action_with!(escape)
      raise ArgumentError unless escape.is_a?(ActionEscape)
      throw :gyngestol_escape, escape
    end

    def _default_response_type
      gyngestol.configuration.default_response_type
    end

  end#Endpoint
end
