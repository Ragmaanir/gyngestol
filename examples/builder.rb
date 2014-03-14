
require 'active_support/core_ext'
require 'pry'

class AnnotationsBuilder
  def initialize(&block)
    @imports = {}
    @annotations = {}
    @variables = {}
    instance_eval(&block)
  end

  def import(dsl)
    @imports << dsl
  end

  def method(name, variables={}, &block)
    raise ArgumentError if name.in?(@annotations.keys)
    @variables.merge!(variables)
    @annotations.merge!(name => block)
  end

  def _result!
    annotations = @annotations

    m = Module.new do
      def method_added(method_name)
        @current_annotations.each do |name, args|
          annotations[name].call(method_name, *args)
        end
      end

      annotations.each do |name, block|
        define_method(name) do |args|
          @current_annotations ||= {}
          @current_annotations.merge!(name => args)
        end
      end
    end

    @variables.each do |name, value|
      m.instance_variable_set("@#{name}", value)
      m.send(:attr_accessor, name)
    end

    m.send(:define_method, :annotations) do
      annotations
    end
    m
  end

end

module Annotations
  def self.define(*args, &block)
    AnnotationsBuilder.new(*args, &block)._result!
  end
end

Actions = Annotations.define do
  method(:action, :actions => {}) do |method_name, options|
    method, url = options.shift
    @actions.merge!([method, url] => method_name)
  end
end

Documentation = Annotations.define do
  method(:describe, :documentations => {}) do |method_name, string|
    @documentations.merge!(method_name => string)
  end
end

class X
  extend Actions
  extend Documentation

  describe 'This is the main index action'
  action get: '/'
  def index
  end
end

class DocumentationGenerator
  def self.generate(cls)
  end
end
