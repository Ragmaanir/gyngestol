describe Gyngestol::RouterBuilder do

  it '' do
    b = described_class.new(Gyngestol::Router, Object) do
    end

    assert{
      b.router == Gyngestol::Router.new(root: Gyngestol::InnerNode.new(route_matcher: nil, children: []))
    }
  end

  it '' do
    class Controller
      def initialize(req)
      end

      def show
      end
    end

    router = described_class.build(Gyngestol::Router, Controller) do
      path 'users' do
        action :get, :show
      end
    end

    assert{
      router == Gyngestol::Router.new(root: Gyngestol::InnerNode.new(route_matcher: nil, children: [
        Gyngestol::InnerNode.new(route_matcher: %r{users}, children: [
          Gyngestol::TerminalNode.new(verb_matcher: ['get'], action: Gyngestol::Action.new(controller: Controller, action: :show))
        ])
      ]))
    }
  end

  # it '' do
  #   class User
  #     def initialize(*args)
  #     end

  #     def show(id)
  #     end
  #   end

  #   r = described_class.build(Gyngestol::Router, Object) do
  #     namespace 'users' do
  #       path :int do
  #         action :get, :show
  #       end
  #     end
  #   end

  #   route = r.route('/users/1337')

  #   route.action.call(Rack::Request.new({}), *route.args)
  # end

end
