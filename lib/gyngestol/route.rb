module Gyngestol
  class Route
    include Virtus.value_object

    values do
      attribute :node, Node
      attribute :args, Array[Object]
    end

    def action
      node.action
    end

    def inspect
      node_str = node.path.map{ |n| n.route_matcher }
      "Route(#{node_str} #{node.verb_matcher})"
    end
  end
end
