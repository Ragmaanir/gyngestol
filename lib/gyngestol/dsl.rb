module Gyngestol
  module DSL

    def self.included(target)
      target.extend ClassMethods
      target.instance_variable_set('@method_annotations', {})
      target.instance_variable_set('@gyngestol_temp', {})
    end

    module ClassMethods

      attr_reader :method_annotations

      def namespace(*args)
        if args.empty?
          @namespace
        else
          @namespace = args.first
        end
      end

      def action(*args)
        @gyngestol_temp[:action] = args
      end

      def describe(*args)
        @gyngestol_temp[:documentation] = args
      end

      def method_added(name)
        @method_annotations[name] = @gyngestol_temp
        @gyngestol_temp = {}
      end

    end

  end#DSL

end
