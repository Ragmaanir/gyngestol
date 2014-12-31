module Gyngestol

  class Request
    include Virtus.value_object

    values do
      attribute :path, String
      attribute :method, String
    end

    def inspect
      "Request(#{method} #{path})"
    end
  end

  class Route
    include Virtus.value_object

    values do
      attribute :nodes, Array[Node]
    end

    def action
      nodes.last.action
    end

    def inspect
      *path, verb = nodes
      node_str = path.map{ |n| n.route_matcher }
      "Route(#{node_str} #{verb.verb_matcher})"
    end
  end

  class Router
    include Virtus.model

    attribute :root, InnerNode

    def route(request)
      request = Request.new(path: request, method: 'get') if request.is_a?(String)

      if terms = find_terminal_nodes_for(request.path)
        term = terms.find{ |t| t.matches?(request.method) }
        Route.new(nodes: term.path) if term
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

  private

    def find_terminal_nodes_for(path)
      raise("path is nil") if path.nil?
      node = root || raise
      remaining_path = path.split('/').reject(&:blank?)

      print "Routing: "

      while node.is_a?(InnerNode) && segment = remaining_path.shift
        print "#{segment} -> "

        node = node.children.find{ |n| n.matches?(segment) }
      end

      if remaining_path.blank? && node.is_a?(InnerNode)
        terminals = node.children.select{ |c| c.is_a?(TerminalNode) }
      end

      puts "Found: #{terminals.inspect}"

      terminals
    end

    def generate_route(node_path)
      Route.new(nodes: node_path)
    end

  end
end
