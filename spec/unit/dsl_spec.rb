describe Gyngestol::DSL do

  it '' do
    class A
      include Gyngestol::DSL

      namespace :a

      describe 'Some action'
      action get: '/'
      def index
      end
    end

    A.namespace.should == :a
    A.method_annotations.should == {
      index: {
        documentation: ['Some action'],
        action: [{get: '/'}]
      }
    }
  end

end
