module Gyngestol
  module RoutingDSL
    #
    # Router.define do
    #   path 'users' do
    #     action :get, :index
    #     action :post, :create
    #
    #     path :int do
    #       action :get, :show
    #       action :put, :update
    #       action :delete, :destroy
    #     end
    #   end
    # end
    #

    # {
    #   Matcher('/') => {
    #     Matcher('users') => {
    #       Matcher(:GET) => Action(:index),
    #       Matcher(:POST) => Action(:create),
    #       Matcher(/d+/) => {
    #         Matcher(:GET) => Action(:show)
    #       }
    #     },
    #     Matcher('topics') => {}
    #   }
    # }

    MATCHERS = {
      :int => %r{\d+}
    }.freeze

    REGISTERED_MATCHERS = IceNine.deep_freeze(
      :int => {route_matcher: %r{\d+}, callback: ->(seg){ Integer(seg, 10) }}
    )

    def path(matcher, &block)
      # attrs = case matcher
      #   when String then {route_matcher: Regexp.new(matcher)}
      #   when Symbol then {route_matcher: MATCHERS[matcher], callback: ->(seg){  } }
      # end

      attrs = case matcher
        when String then {route_matcher: Regexp.new(matcher)}
        when Symbol then REGISTERED_MATCHERS[matcher]
      end

      node = InnerNode.new(attrs)

      new_child_node(node, &block)
    end

    def namespace(matcher, &block)
      raise ArgumentError unless matcher.is_a?(String)

      ns = current_namespace.const_get(matcher.singularize.camelcase)

      node = InnerNode.new(route_matcher: Regexp.new(matcher), namespace: ns)

      new_child_node(node, &block)
    end

    def action(verb, action_name, options={})
      verb = verb.to_s if verb.is_a?(Symbol)
      verb = [verb] unless verb.is_a?(Array)
      #cls = options[:class] || infer_current_class(node_stack.drop(1).map(&:route_matcher))

      # cls = case options[:class]
      #   #when Symbol, String then infer_current_class(node_stack.drop(1).map(&:route_matcher)).const_get(options[:class].to_s)
      #   when Symbol, String then root_namespace.const_get(options[:class].to_s)
      #   when nil then infer_current_class(node_stack.drop(1).map(&:route_matcher))
      # end

      cls = case options[:class]
        # FIXME dont look it up in root, instead look it up in current namespace, unless string starts with ::
        when Symbol, String then root_namespace.const_get(options[:class].to_s)
        # FIXME allow classes
        when nil then current_namespace
      end

      action = Action.new(controller: cls, action: action_name)

      #node_stack.last.children << TerminalNode.new(verb_matcher: verb, action: action)
      node = TerminalNode.new(verb_matcher: verb, action: action)

      new_child_node(node)
    end

  private

    def current_namespace
      node_stack.last.namespace || raise
    end

    def new_child_node(node, &block)
      node.parent = node_stack.last
      node_stack << node

      instance_eval(&block) if block

      node_stack.pop
      node_stack.last.children << node
    end

    # [InnerNode(/backend/), InnerNode(/users/), TerminalNode] #=> Backend::Users
    def infer_current_class(matchers)
      matchers.inject(root_namespace) do |namespace, matcher|
        const_name = matcher.source[0..-2].camelcase

        if namespace.const_defined?(const_name)
          namespace.const_get(const_name)
        else
          nil
        end
      end
    end

  end
end
