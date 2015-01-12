module Gyngestol

  class TerminalNode < Node
    attribute :verb_matcher, Array[String], default: HttpUtils::REQUEST_METHODS
    attribute :action, Action

    def match(verb)
      verb.downcase.in?(verb_matcher)
    end

    def equal_node?(other)
      verb_matcher == other.verb_matcher && action == other.action
    end

    def inspect
      "TerminalNode(verb_matcher: #{verb_matcher.inspect}, action: #{action.inspect})"
    end
  end

end
