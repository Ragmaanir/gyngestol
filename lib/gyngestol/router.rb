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

  class Router
    include Virtus.model

    attribute :root, InnerNode

    def route(request)
      request = Rack::Request.new('PATH_INFO' => request, 'REQUEST_METHOD' => 'get') if request.is_a?(String)

      node = root || raise
      remaining_path = request.path.split('/').reject(&:blank?)
      args = []

      while node.is_a?(InnerNode) && segment = remaining_path.shift
        if node = node.children.find{ |n| n.matches?(segment) }
          args << node.callback.call(segment) if node.callback
        end
      end

      if remaining_path.blank? && node.is_a?(InnerNode)
        terminals = node.children.select{ |c| c.is_a?(TerminalNode) }

        term = terminals.find{ |t| t.matches?(request.request_method) }

        return Route.new(node: term, args: args) if term
      end
    end

    def routes?(request)
      route(request).present?
    end

    def ==(other)
      case other
        when Router then root == other.root
        else false
      end
    end

  end
end
