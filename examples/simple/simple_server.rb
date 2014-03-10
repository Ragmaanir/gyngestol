require ::File.expand_path('../../../lib/gyngestol',  __FILE__)

require 'thin'

class SimpleServer
  include Gyngestol::Endpoint

  action get: '/'
  def index
    respond_with :json, "Index: #{Time.now}"
  end

  action get: '/status'
  def show
    respond_with :json, "Show: #{request.env}"
  end

end

builder = Rack::Builder.new do
  #use Rack::CommonLogger
  use Rack::Reloader
  run SimpleServer
end
Rack::Handler::Thin.run builder, port: 8080

#Rack::Handler::Thin.run SimpleServer, port: 8080
