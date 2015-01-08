module Gyngestol

  HTTP_VERBS = %w{head get post put delete}

  class TerminalNode < Node
    attribute :verb_matcher, Array[String], default: HTTP_VERBS
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
