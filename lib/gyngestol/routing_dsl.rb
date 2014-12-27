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


    # Matcher = Gyngestol::RouteMatcher

    # class Node
    #   include Virtus.model

    #   attribute :matcher, Matcher
    #   attribute :children, Array[Node]
    #   attribute :action, Symbol
    # end

    def path(matcher, &block)
      #nodes << Node.new(matcher, [])
      #nodes << {matcher => {}}
      #matcher_stack << Matcher.new(regex: matcher)
      #children_stack << {}
      #node = Node.new(matcher: Matcher.new(regex: matcher))
      #node = InnerNode.new(matcher: Matcher.new(regex: Regexp.new(matcher+'/')))
      node = InnerNode.new(route_matcher: Regexp.new(matcher+'/'))
      node_stack << node

      instance_eval(&block)

      #matcher_stack.pop
      #children_stack.pop
      node_stack.pop
      node_stack.last.children << node
    end

    def action(verb, action_name, options={})
      verb = verb.to_s if verb.is_a?(Symbol)
      verb = [verb] unless verb.is_a?(Array)
      cls = options[:class] || infer_current_class(node_stack.drop(1).map(&:route_matcher))
      action = Action.new(cls, action_name)
      #children_stack.last.merge!(Matcher.new(regex: action_name) => action)
      #children_stack.last.merge!(Matcher.new(verb, action_name) => action)
      node_stack.last.children << TerminalNode.new(verb_matcher: verb, action: action)
    end

  private

    # [Matcher(/backend/), Matcher(/users/)] #=> Backend::Users
    def infer_current_class(matchers)
      matchers.inject(root_namespace) do |namespace, matcher|
        const_name = matcher.source[0..-2].camelcase

        if namespace.const_defined?(const_name)
          namespace.const_get(const_name)
        else
          return nil
        end
      end
    end

  end
end
