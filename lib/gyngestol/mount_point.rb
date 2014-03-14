module Gyngestol
  class MountPoint
    def initialize(endpoint_class)
      raise ArgumentError unless endpoint_class < Endpoint
      @endpoint_class = endpoint_class

      @actions = @endpoint_class.method_annotations.map{ |method_name, annotations|
        verb, url = annotations[:action].first.shift

        Action.new(url, verb, method_name)
      }
    end

    include Escapes

    class Action < Struct.new(:url, :verb, :action_name)
      def matches?(path, other_verb)
        url === path && verb.downcase.to_s == other_verb.downcase.to_s
      end
    end

    def route(actions, request)
      @actions.find{ |action| action.matches?(request.path, request.request_method)  }
    end

    def call(env)
      result = nil

      request = Rack::Request.new(env)
      response = Rack::Response.new

      endpoint = @endpoint_class.new(request, response)

      action = route(@actions, request)

      action_name = action.action_name if action
      #time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      #puts "[#{time} | #{env['REMOTE_ADDR']}] #{env['REQUEST_PATH']} #{ENV['REQUEST_METHOD']} => #{action_name || '!!!'}"

      result = catch(:gyngestol_escape) do
        throw(:gyngestol_escape, ActionNotFoundEscape.new(request)) unless action

        endpoint.send(action_name)
      end

      case result
        when ActionEscape then
          result.response
        when Escape then
          if endpoint.escape_handler
            escape_handler.call(result)
          else
            default_escape_handler(result)
          end
        else result
      end
    end

    def default_escape_handler(escape)
      status_response(escape.status, text: escape.response)
    end

  end
end
