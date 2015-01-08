module Gyngestol
  class App
    include Virtus.model
    include Escapes

    attribute :router

    def call(env)
      request = Request.new(method: env['REQUEST_METHOD'].downcase, path: env['PATH_INFO'].downcase)

      if route = router.route(request)

        result = catch(:gyngestol_escape) do
          route.action.call(Rack::Request.new(env), route.args)
        end

        response = case result
          when ActionEscape
            result.response
          when Escape then
            if route.action.controller.escape_handler
              escape_handler.call(result)
            else
              default_escape_handler(result)
            end
          else status_response(200, text: result.to_s)
        end

        response
      else
        status_response(404)
      end
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
      status_response(500)
    end

    def default_escape_handler(escape)
      status_response(escape.status, text: escape.response)
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
end
