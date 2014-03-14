
module Annotations

  def self.included(target)
    target.extend ClassMethods
    target.instance_variable_set('@method_annotations', {})
    target.instance_variable_set('@gyngestol_temp', {})
  end

  module ClassMethods

    attr_reader :method_annotations
    def action(*args)
      @gyngestol_temp[:action] = args
    end

    def describe(*args)
      @gyngestol_temp[:documentation] = args
    end

    def method_added(name)
      @method_annotations[name] = @gyngestol_temp
    end
  end
end

class X
  include Annotations

  describe 'This is the index action'
  action get: '/'
  def index
  end
end

class DocumentationGenerator
  def self.generate(cls)
    doc = ""
    cls.method_annotations.each do |method_name, annotations|
      doc += "#{annotations[:action].first} => #{method_name} : #{annotations[:documentation].first}"
    end
    doc
  end
end

p DocumentationGenerator.generate(X)
