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

    included do

      include Escapes

      cattr_reader :escape_handler

      class Action < Struct.new(:url, :verb, :action_name)
        def matches?(path, other_verb)
          url === path && verb.downcase.to_s == other_verb.downcase.to_s
        end
      end

      def self.route(actions, request)
        @actions ||= self.method_annotations.map{ |method_name, annotations|
          verb, url = annotations[:action].first.shift

          Action.new(url, verb, method_name)
        }

        @actions.find{ |action| action.matches?(request.path, request.request_method)  }
      end

      def self.call(env)
        result = nil

        result = catch(:gyngestol_escape) do
          request = Rack::Request.new(env)
          response = Rack::Response.new

          action = route(@actions, request)

          action_name = action.action_name if action
          time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          puts "[#{time} | #{env['REMOTE_ADDR']}] #{env['REQUEST_PATH']} #{ENV['REQUEST_METHOD']} => #{action_name || '!!!'}"

          throw(:gyngestol_escape, ActionNotFoundEscape.new(request)) unless action

          new(request, response).send(action_name)
        end

        case result
          when ActionEscape then
            result.response
          when Escape then
            if escape_handler
              escape_handler.call(result)
            else
              default_escape_handler(result)
            end
          else result
        end
      end

      def self.status_response(status, content_type: :json, text: DEFAULT_STATUS_MESSAGES[status])
        [status, {"Content-Type" => CONTENT_TYPES[content_type]}, [text]]
      end

      def self.default_escape_handler(escape)
        status_response(escape.status, text: escape.response)
      end

      include DSL

    end

    def initialize(request, response)
      @request = request
      @response = response
    end

    def request
      @request
    end

    def params
      request.params.dup.with_indifferent_access
    end

    def respond_with(format, text)
      throw :gyngestol_escape, ActionEscape.new(request, self.class.status_response(200, content_type: format, text: text))
    end

  end
end
