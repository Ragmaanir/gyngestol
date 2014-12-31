module Gyngestol

  class InnerNode < Node
    attribute :route_matcher, Regexp
    attribute :children, Array[Node]

    def children=(nodes)
      @children = nodes
      @children.each{ |c| c.parent = self }
    end

    def match(path_segment)
      route_matcher.nil? || route_matcher.match(path_segment)
    end

    def equal_node?(other)
      route_matcher == other.route_matcher &&
      children.zip(other.children).all? { |a,b| a == b || binding.pry }
    end

    def inspect
      "InnerNode(route_matcher: #{route_matcher.inspect}, children: #{children.inspect})"
    end
  end

end
