module Gyngestol
  module RoutingDSL
    include BaseDSL

    add_method(:action) do |context, method_name, options|
      http_method, url = options.shift

      raise if context[:action]
      raise ArgumentError, "Got #{method.inspect}, expected one of #{HTTP_METHODS}" unless method.to_s.in?(HTTP_METHODS)

      context[:actions] ||= []
      context[:actions] << Action.new(url, method.upcase.to_s, options)
    end

  end
end
