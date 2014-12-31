describe Gyngestol::RouterBuilder do

  it '' do
    b = described_class.new(Gyngestol::Router, Object) do
    end

    assert{
      b.router == Gyngestol::Router.new(root: Gyngestol::InnerNode.new(route_matcher: nil, children: []))
    }
  end

  it '' do
    b = described_class.new(Gyngestol::Router, Object) do
      path 'users' do
        action :get, :show
      end
    end

    assert{
      b.router == Gyngestol::Router.new(root: Gyngestol::InnerNode.new(route_matcher: nil, children: [
        Gyngestol::InnerNode.new(route_matcher: %r{users}, children: [
          Gyngestol::TerminalNode.new(verb_matcher: ['get'], action: Gyngestol::Action.new(nil, :show))
        ])
      ]))
    }
  end

end
