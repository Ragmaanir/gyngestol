require ::File.expand_path('../../lib/gyngestol',  __FILE__)

require 'thin'

module SimpleServer
  module Controllers
    class Root
      include Gyngestol::Endpoint

      def show
        respond_with(:json, '{}')
      end

      def create
        respond_with(:json, '{success: true}')
      end
    end
  end
end

router = Gyngestol::RouterBuilder.build(Gyngestol::Router, SimpleServer::Controllers) do
  #action :get, :show, class: SimpleServer::Controllers::Root
  #action :post, :create, class: SimpleServer::Controllers::Root

  action :get, :show, class: :Root
  action :post, :create, class: :Root
end

builder = Rack::Builder.new do
  run Gyngestol::App.new(router: router)
end

Rack::Handler::Thin.run builder, port: 8080
