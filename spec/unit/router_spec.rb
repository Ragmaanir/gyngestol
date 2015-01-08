describe Gyngestol::Router do

  context '#routes?' do
    it '' do
      router = described_class.new(root: Gyngestol::InnerNode.new(children: [
        Gyngestol::InnerNode.new(route_matcher: %r{users}, children: [
          Gyngestol::TerminalNode.new()
        ])
      ]))

      assert { router.routes?('/users') == true }
      assert { router.routes?('/test') == false }
      assert { router.routes?('/') == false }
      assert { router.routes?('/users/1') == false }
    end
  end

  context '#route' do
    it '' do
      router = described_class.new(root: Gyngestol::InnerNode.new(children: [
        Gyngestol::InnerNode.new(
          route_matcher: %r{users},
          children: [Gyngestol::TerminalNode.new(verb_matcher: ['get'])]
        ),
        Gyngestol::TerminalNode.new()
      ]))

      assert { router.route('/') == Gyngestol::Route.new(node: router.root.children.last) }
      assert { router.route('/users') == Gyngestol::Route.new(node: router.root.children.first.children.first) }
      assert { router.route('/test') == nil }
    end
  end

end
