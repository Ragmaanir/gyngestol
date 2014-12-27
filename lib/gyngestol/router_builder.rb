module Gyngestol
  class RouterBuilder
    include Virtus.model
    include Gyngestol::RoutingDSL

    attribute :router, Router
    attribute :root_namespace, Object

    def initialize(cls, root_namespace, &block)
      @root_namespace = root_namespace
      # @matcher_stack = []
      # @children_stack = []
      #@node_stack = [Gyngestol::RoutingDSL::Node.new(matcher: Matcher.new(regex: //), children: [])]
      #@node_stack = [Gyngestol::RoutingDSL::Node.new(matcher: SLASH_MATCHER, children: [])]
      @node_stack = [Gyngestol::InnerNode.new(children: [])]

      instance_eval(&block)

      @router = construct_router(cls)
    end

  private

    #attr_accessor :matcher_stack, :children_stack
    attribute :node_stack, Array[Gyngestol::Node]

    def construct_router(cls)
      router = cls.new(root: node_stack.first)

      router
    end

  end
end
