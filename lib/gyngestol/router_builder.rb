module Gyngestol
  class RouterBuilder
    include Virtus.model
    include Gyngestol::RoutingDSL

    attribute :router, Router
    attribute :root_namespace, Object

    def initialize(cls, root_namespace, &block)
      @root_namespace = root_namespace

      @node_stack = [Gyngestol::InnerNode.new(children: [])]

      instance_eval(&block)

      @router = construct_router(cls)
    end

    def self.build(*args, &block)
      new(*args, &block).router
    end

  private

    attribute :node_stack, Array[Gyngestol::Node]

    def construct_router(cls)
      router = cls.new(root: node_stack.first)

      router
    end

  end
end
