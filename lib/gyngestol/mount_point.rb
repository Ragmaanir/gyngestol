module Gyngestol
  class MountPoint
    def initialize(endpoint)
      raise ArgumentError unless endpoint.kind_of?(Endpoint)
      @endpoint = endpoint
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new

      @endpoint
    end
  end
end
