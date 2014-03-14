
require 'active_support/all'
require 'wrong'
require 'pry'

include Wrong

module DSL

  # def self.included(target)
  #   if target.is_a? Class

  #   else
  #     target.extend ClassMethods
  #   end
  # end

  module Meta
    def definition
      Module.new do
        def self.included(target)
          target.extend DSLClassMethods
          target.extend Meta
          target.extend ExtendMe
        end
      end
    end

    module ExtendMe
      def included(target)
        target.extend ClassClassMethods
      end
    end

    extend ExtendMe
  end



  module DSLClassMethods

    def add_method(name, &block)
      puts "Registered DSL method: #{name} in #{self.inspect}"

      @gyngestol_methods ||= {}
      @gyngestol_methods.merge(name => block)

      # @gyngestol_stubs ||= {}
      # @gyngestol_stubs.merge name => ->(*args, &block){
      #   puts "Invoked DSL method #{name}"
      #   @gyngestol_annotations ||= {}
      #   @gyngestol_annotations.merge(name: [args, block])
      # }

      define_method(name) do |*args, &block|
        puts "Invoked DSL method #{name}"
        @gyngestol_annotations ||= {}
        @gyngestol_annotations.merge(name: [args, block])
      end
    end
  end

  module ClassClassMethods
    def method_added(name,&block)
      puts "Defined method #{name}"

      @gyngestol_methods.each do |name, block|
        puts "Calling #{name}"
        block.call(annotations)
      end
    end
  end

  extend Meta

end

assert { DSL::Meta.respond_to?(:included) }
assert { DSL.respond_to?(:definition) }

module TestDSL
  include DSL.definition
end

assert { TestDSL.respond_to?(:add_method) }
assert { TestDSL.respond_to?(:included) }
assert { TestDSL.respond_to?(:definition) }

module ActionDSL
  include DSL.definition

  add_method(:action) do |args|
  end
end

module DocumentationDSL
  include ActionDSL.definition

  add_method(:describe) do |args, &block|
  end
end

class X
  #extend MyDSL
  #extend DocumentationDSL
  include ActionDSL


  #describe 'test'
  action :x
  def my_action
  end
end

binding.pry
