module Gyngestol

  HTTP_VERBS = %w{head get post put delete}

  # class Match
  #   include Virtus.model

  #   attribute :match, MatchData

  #   def arguments
  #     match.captures
  #   end

  #   delegate :post_match, to: :match

  #   def inspect
  #     # "Match(matched: #{match[0].inspect}, remains: #{match.post_match.inspect}, arguments: #{arguments})"
  #     "Match(matched: #{match.inspect})"
  #   end
  # end

  # class RouteConstraint
  #   include Virtus.model

  #   attribute :path_constraint, Object, default: nil
  #   attribute :method_constraint, Array[String], default: nil

  #   def satisfied?(method, path)
  #     path_constraint_satisfied?(path) && method_constraint_satisfied(method)
  #   end

  #   def path_constraint_satisfied?(path)
  #     case path_constraint
  #       when String then path_constraint == path
  #       when Regex then path_constraint === path
  #       else raise ArgumentError
  #     end
  #   end

  #   def method_constraint_satisfied?(method)
  #     raise ArgumentError unless method.in?(HTTP_VERBS)

  #     method_constraint.include?(method)
  #   end
  # end

  # class RouteMatcher
  #   include Virtus.model

  #   attribute :regex, Regexp
  #   attribute :methods, Array[String], default: HTTP_VERBS

  #   def match(method, route_str)
  #     raise ArgumentError unless method.in?(HTTP_VERBS)

  #     if methods.include?(method)
  #       if regex
  #         case m = regex.match(route_str)
  #           when MatchData
  #             Match.new(match: m) if m.pre_match.blank? && m.post_match.blank?
  #           else nil
  #         end
  #       else
  #         Match.new
  #       end
  #     end
  #   end

  #   def inspect
  #     ms = if methods == HTTP_VERBS
  #       '*'
  #     else
  #       methods
  #     end

  #     "RouteMatcher(regex: #{regex.inspect}, methods: #{ms.inspect})"
  #   end
  # end

  Action = Struct.new(:controller, :action)

  class Node
    include Virtus.model

    attribute :parent, Node, default: nil

    def path
      node = self
      node_path = [node]

      while node.parent
        node = node.parent
        node_path.unshift(node)
      end

      node_path
    end

    def match(arg)
      raise NotImplementedError
    end

    def matches?(arg)
      match(arg).present?
    end

    def ==(other)
      case other
        when self.class then parent == other.parent && equal_node?(other)
        else false
      end
    end
  end

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
      route_matcher == other.route_matcher
    end

    def inspect
      "InnerNode(route_matcher: #{route_matcher.inspect}, children: #{children.inspect})"
    end
  end

  class TerminalNode < Node
    attribute :verb_matcher, Array[String], default: HTTP_VERBS
    attribute :action, Action

    def match(verb)
      verb.in?(verb_matcher)
    end

    def equal_node?(other)
      verb_matcher == other.verb_matcher
    end

    def inspect
      "TerminalNode(verb_matcher: #{verb_matcher.inspect})"
    end
  end

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

      route_impl2(request)
    end

    def route_impl1(request)
      remaining_path = request.path.split('/').reject(&:blank?)
      nodes = root.children
      node_path = []

      while !node_path.last.is_a?(TerminalNode) #nodes.present?
        segment = remaining_path.shift

        matching_node, match = *find_matching_node(nodes, request.method, segment)

        if matching_node
          nodes = case matching_node
            when InnerNode then matching_node.children
            when TerminalNode then []
            else raise
          end

          node_path << matching_node
        else
          nodes = []
        end
      end

      case matching_node
        when TerminalNode then generate_route(node_path)
        when InnerNode, nil then nil
        else raise
      end unless remaining_path.present?
    end

    def route_impl2(request)
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

    def find_matching_node(nodes, method, segment)
      matching_node = nodes.find{ |n|
        #n.matcher.match(method, segment)
        case n
          when InnerNode then n.matches?(segment, method)
          when TerminalNode then n.matches?(segment, method)
        end
      }

      if matching_node
        match = matching_node.match(method, segment)
      end

      [matching_node, match]
    end

    def find_terminal_nodes_for(path)
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
