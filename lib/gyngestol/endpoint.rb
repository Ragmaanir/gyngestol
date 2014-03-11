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

    class Router
      def route(actions, request)
        raise NotImplementedError
      end
    end

    class SimpleRouter < Router
      def initialize(actions)
        @actions = actions
      end

      def route(actions, request)
        @actions.find{ |action| action.matches?(request.path, request.request_method)  }
      end
    end

    class RouterBuilder
      def add_action(action)
      end

      def result
      end
    end

    class SimpleRouterBuilder < RouterBuilder

      attr_reader :result

      def initialize
        @result = []
      end

      def add_action(action)
        @result << action
      end
    end

    included do
      attr_reader :actions

      include DSL

      @actions = []
      @invoked_methods = {}
    end

    module DSL

      @dsl_methods = {}

      def self.add_method(name, &block)
        @dsl_methods.merge!(name => block)

        self.define_method(name) do |*args|
          @invoked_methods[name] = *args
        end
      end

      def action(options)
        method, url = options.shift
        raise if @last_action
        raise ArgumentError, "Got #{method.inspect}, expected one of #{HTTP_METHODS}" unless method.to_s.in?(HTTP_METHODS)

        @last_action = Action.new(url, method.upcase.to_s, options)
        @actions << @last_action
      end

      def method_added(meth)
        @last_action.options.merge!(method_name: meth)

        @invoked_methods.each do |name, args|
          @dsl_methods[name].call(@last_action, *args)
        end

        @last_action = nil
      end

    end

    module ClassMethods

      include Escapes

      attr_reader :escape_handler

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
