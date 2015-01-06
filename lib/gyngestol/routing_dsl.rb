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

    def path(matcher, &block)
      matcher = case matcher
        when String then Regexp.new(matcher)
        when Symbol then MATCHERS[matcher]
      end

      node = InnerNode.new(route_matcher: matcher)
      node_stack << node

      instance_eval(&block)

      node_stack.pop
      node.parent = node_stack.last
      node_stack.last.children << node
    end

    def action(verb, action_name, options={})
      verb = verb.to_s if verb.is_a?(Symbol)
      verb = [verb] unless verb.is_a?(Array)
      #cls = options[:class] || infer_current_class(node_stack.drop(1).map(&:route_matcher))

      cls = case options[:class]
        #when Symbol, String then infer_current_class(node_stack.drop(1).map(&:route_matcher)).const_get(options[:class].to_s)
        when Symbol, String then root_namespace.const_get(options[:class].to_s)
        when nil then infer_current_class(node_stack.drop(1).map(&:route_matcher))
      end

      action = Action.new(cls, action_name)

      node_stack.last.children << TerminalNode.new(verb_matcher: verb, action: action)
    end

  private

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
