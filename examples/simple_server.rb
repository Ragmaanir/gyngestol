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

    class User
      def initialize(req)
      end

      def show(id)
        p id
      end
    end
  end
end

router = Gyngestol::RouterBuilder.build(Gyngestol::Router, SimpleServer::Controllers) do
  get :show, class: :Root
  post :create, class: :Root

  namespace 'users' do
    path :int do
      get :show
    end
  end
end

builder = Rack::Builder.new do
  run Gyngestol::App.new(router: router)
end

Rack::Handler::Thin.run builder, port: 8080
