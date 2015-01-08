module Gyngestol

  class Node
    include Virtus.model

    attribute :parent, Node, default: nil
    attribute :namespace, Object
    attribute :callback, Proc, default: nil

    def namespace
      super || parent.try(:namespace)
    end

    def path
      node = self
      node_path = []

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
        when self.class then equal_node?(other)
        else false
      end
    end
  end

end
