module Gyngestol
  class App
    include Virtus.model
    include Escapes
    include HttpUtils

    attribute :router
    attribute :configuration, Configuration, default: Configuration.new

    def call(env)
      request = wrap_env(env)

      if route = router.route(request)

        result = catch(:gyngestol_escape) do
          route.action.call(request, route.args)
        end

        response = case result
          when ActionEscape
            result.response
          when Escape then
            if route.action.controller.escape_handler
              escape_handler.call(result)
            else
              handle_escape(result)
            end
          else status_response(200, data: result)
        end

        raise unless response.is_a?(Array)

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
        ensure_response(self.instance_exec(request, error, &configuration.default_error_handler))
      else
        status_response(configuration.error_status)
      end
    end

    def handle_missing_route(request)
      if configuration.default_missing_route_handler
        ensure_response(self.instance_exec(request, &configuration.default_missing_route_handler))
      else
        status_response(configuration.missing_route_status)
      end
    end

    def handle_escape(escape)
      if configuration.default_escape_handler
        ensure_response(self.instance_exec(escape, &configuration.default_escape_handler))
      else
        status_response(escape.status, data: escape.response)
      end
    end

    def status_response(status, content_type: configuration.default_response_type, data: DEFAULT_STATUS_MESSAGES[status])
      [status, {"Content-Type" => CONTENT_TYPES[content_type]}, [data.to_s]]
    end

    def ensure_response(resp)
      raise "Response is not an array: #{resp.inspect}" unless resp.is_a?(Array)
      raise "Response array length must be 3 but was: #{resp.length}" unless resp.length == 3
      resp
    end

    def wrap_env(env)
      Rack::Request.new(env)
    end

  end
end
