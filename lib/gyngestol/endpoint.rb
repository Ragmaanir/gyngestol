require 'active_support/concern'
require 'active_support/hash_with_indifferent_access'

module Gyngestol
  module Endpoint

    HTTP_METHODS = %w{head get put post delete}

    extend ActiveSupport::Concern
    include Escapes

    class Action < Struct.new(:url, :method, :options)
      def matches?(path, meth)
        res = url === path && method == meth
        res
      end
    end

    included do
      attr_reader :actions

      @actions = []
    end

    module ClassMethods

      include Escapes

      attr_reader :escape_handler

      def action(options)
        method, url = options.shift
        raise ArgumentError, "Got #{method.inspect}, expected one of #{HTTP_METHODS}" unless method.to_s.in?(HTTP_METHODS)
        @last_action = Action.new(url, method.upcase.to_s, options)
        @actions << @last_action
      end

      def method_added(meth)
        if @last_action
          @last_action.options.merge!(method_name: meth)
          @last_action = nil
        end
      end

      def find_action(actions, request)
        actions.find{ |action| action.matches?(request.path, request.request_method)  }
      end

      def call(env)
        result = nil

        result = catch(:gyngestol_escape) do
          request = Rack::Request.new(env)
          response = Rack::Response.new

          action = find_action(@actions, request)

          action_name = action.options[:method_name] if action
          time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
          puts "[#{time} | #{env['REMOTE_ADDR']}] #{env['REQUEST_PATH']} #{ENV['REQUEST_METHOD']} => #{action_name || '!!!'}"

          throw(:gyngestol_escape, ActionNotFoundEscape.new(request)) unless action

          new(request, response).send(action.options[:method_name])
        end

        case result
          when ActionEscape then
            result.response
          when Escape then
            if escape_handler
              escape_handler.call(escape)
            else
              status_response(500)
            end
          else result
        end
      end

      DEFAULT_STATUS_MESSAGES = {
        500 => 'Internal Server Error',
        200 => 'Ok',
        404 => 'Not Found'
      }

      CONTENT_TYPES = {
        :json => 'application/json'
      }

      def status_response(status, content_type: :json, text: DEFAULT_STATUS_MESSAGES[status])
        [status, {"Content-Type" => CONTENT_TYPES[content_type]}, [text]]
      end

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
