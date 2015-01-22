require 'json'

module Gyngestol
  class App
    include Virtus.model
    include Escapes
    include HttpUtils

    attribute :router, Router
    attribute :configuration, Configuration, default: Configuration.new
    attribute :logger, Logger, default: NullLogger.new

    def call(env)
      request = wrap_env(env)

      if route = router.route(request)

        result = catch(:gyngestol_escape) do
          route.action.call(self, request, route.args)
        end

        response = case result
          when ActionEscape
            result.response
          when Escape
            if route.action.controller.escape_handler
              escape_handler.call(result)
            else
              handle_escape(result)
            end
          when Rack::Response
            result.finish
          else
            format ||= configuration.default_response_type

            format_response(format, result)
        end

        ensure_response!(response)

        response
      else
        handle_missing_route(request)
      end
    rescue StandardError => e
      handle_error(request, e)
    end

  private

    def handle_error(request, error)
      if configuration.default_error_handler
        exec_response_handler(configuration.default_error_handler, request, error)
      else
        status_response(configuration.error_status)
      end
    end

    def handle_missing_route(request)
      if configuration.default_missing_route_handler
        exec_response_handler(configuration.default_missing_route_handler, request)
      else
        status_response(configuration.missing_route_status)
      end
    end

    def handle_escape(escape)
      if configuration.default_escape_handler
        exec_response_handler(configuration.default_escape_handler, escape)
      else
        status_response(escape.status, data: escape.response)
      end
    end

    def format_response(format, response)
      data = case format
        when :json
          raise unless response.class.in?([Hash,Array])
          JSON.generate(response)
        when :text
          response.to_s
      end

      status_response(200, content_type: format, data: data)
    end

    # Used to run e.g. error handlers in the context of the app so you can
    # use helper methods. Also it makes sure that the result is a valid response.
    def exec_response_handler(handler, *args)
      ensure_response!(self.instance_exec(*args, &handler))
    end

    def status_response(status, content_type: configuration.default_response_type, data: DEFAULT_STATUS_MESSAGES[status])
      [status, {"Content-Type" => CONTENT_TYPES[content_type]}, [data.to_s]]
    end

    # def redirect_to(url, type=:temporary)
    #   resp = Rack::Response.new
    #   resp.redirect(url)
    #   resp
    # end

    def ensure_response!(resp)
      raise "Response is not an array: #{resp.inspect}" unless resp.is_a?(Array)
      raise "Response array length must be 3 but was: #{resp.length}" unless resp.length == 3
      resp
    end

    def wrap_env(env)
      Rack::Request.new(env)
    end

  end
end
