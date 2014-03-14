module Gyngestol
  module BaseDSL

    extend ActiveSupport::Concern

    included do

      @dsl_methods      = {}
      @annotations      = {}

      def self.inject!(target)
        if self.is_a?(Module)
          inject_module!(target)
        else
          inject_class!(target)
        end
      end

      inject!(self)

      def self.inject_module!(target)
        def self.add_method(name, &block)
          @dsl_methods.merge!(name => block)
        end
      end

      def self.inject_class!(target)
        @annotations[name] = {}

        @dsl_methods.each do |name|
          target.send :define_method, name do |*args|
            @annotations[name] = *args
          end
        end
      end

      def method_added(method_name)
        @annotations.each do |name, args|
          @dsl_methods[name].call(@annotations, method_name, *args)
        end

        @annotations = {}
      end

    end

  end#BaseDSL
end#Gyngestol
