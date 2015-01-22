module Gyngestol
  class Configuration
    include Virtus.value_object

    values do
      attribute :default_response_type, Symbol, default: :json
      attribute :default_missing_route_handler, Proc
      attribute :default_escape_handler, Proc

      attribute :default_error_handler, Proc, default: lambda { |_,_|
        ->(request, error) {
          logger.error{ "Caught #{error.class}: #{error.message}" }
          logger.error{ error.backtrace.join("\n") }
          status_response(500)
        }
      }

      attribute :missing_route_status, Integer, default: 404
      attribute :error_status, Integer, default: 500
    end
  end
end
