module Gyngestol
  module Escapes

    class Escape

      attr_reader :request, :reason

      def initialize(request, reason)
        @request = request
        @reason = reason
      end

      def to_s
        reason
      end

    end

    class ActionEscape < Escape
      attr_reader :response

      def initialize(request, response)
        super(request, reason: 'Action terminated')
        @response = response
      end
    end

    class ActionNotFoundEscape < Escape
      def initialize(request, reason: 'Action not found')
        super(request, reason)
      end
    end

  end#Escapes
end#Gyngestol
