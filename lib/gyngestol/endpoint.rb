require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'

module Gyngestol
  module Endpoint

    extend ActiveSupport::Concern
    include Escapes

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
      response = status_response(200, content_type: format, text: text)
      escape_action_with!(ActionEscape.new(request, response))
    end

    def status_response(status, content_type: :json, text: HttpUtils::DEFAULT_STATUS_MESSAGES[status])
      [status, {"Content-Type" => HttpUtils::CONTENT_TYPES[content_type]}, [text]]
    end

    def escape_action_with!(escape)
      raise ArgumentError unless escape.is_a?(ActionEscape)
      throw :gyngestol_escape, escape
    end

  end#Endpoint
end
