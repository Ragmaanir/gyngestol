module Gyngestol
  class RouterBuilder
    include Virtus.model
    include Gyngestol::RoutingDSL

    attribute :router, Router
    attribute :root_namespace, Object

    def initialize(namespace: Object, klass: Gyngestol::Router, &block)
      @root_namespace = namespace

      @node_stack = [Gyngestol::InnerNode.new(children: [], namespace: @root_namespace)]

      instance_eval(&block)

      @router = construct_router(klass)
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
