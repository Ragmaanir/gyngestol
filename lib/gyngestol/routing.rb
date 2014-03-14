module Gyngestol
  module Routing

    class Action < Struct.new(:url, :method, :options)
      def matches?(path, meth)
        res = url === path && method == meth
        res
      end
    end

    class Router
      def route(actions, request)
        raise NotImplementedError
      end
    end

    class SimpleRouter < Router
      def initialize(actions)
        @actions = actions
      end

      def route(actions, request)
        @actions.find{ |action| action.matches?(request.path, request.request_method)  }
      end
    end

    class RouterBuilder
      def add_action(action)
      end

      def result
      end
    end

    class SimpleRouterBuilder < RouterBuilder

      attr_reader :result

      def initialize
        @result = []
      end

      def add_action(action)
        @result << action
      end
    end

  end
end
