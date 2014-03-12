
require 'active_support/all'
require 'pry'

module DSL

  def self.included(target)
    target.extend ClassMethods
  end

  def method_added(name,&block)
    puts "Defined method #{name}"

    @gyngestol_methods.each do |name, block|
      puts "Calling #{name}"
      block.call(annotations)
    end
  end

  module ClassMethods
    def included(target)
      target.extend ClassMethods
    end

    def add_method(name, &block)
      puts "Registered DSL method: #{name}"

      @gyngestol_methods ||= {}
      @gyngestol_methods.merge(name: block)

      define_method(name) do |*args, &block|
        puts "Invoked DSL method #{name}"
        @gyngestol_annotations ||= {}
        @gyngestol_annotations.merge(name: [args, block])
      end
    end
  end

end

module ActionDSL
  include DSL

  add_method(:action) do |args|
  end
end

module DocumentationDSL
  include ActionDSL

  add_method(:describe) do |args, &block|
  end
end

class X
  #extend MyDSL
  extend DocumentationDSL


  describe 'test'
  action :x
  binding.pry
  def my_action
  end
end
