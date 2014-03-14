# describe Gyngestol::BaseDSL do

#   it 'has a add_method-method' do
#     module MyDSL
#       include Gyngestol::BaseDSL
#     end

#     MyDSL.should respond_to(:add_method)
#   end

#   it 'responds to foo' do
#     module MyDSL
#       include Gyngestol::BaseDSL

#       add_method :foo do |annotations|
#       end
#     end

#     class Test
#       include MyDSL
#     end

#     MyDSL.should_not respond_to(:foo)
#     Test.should respond_to(:foo)
#   end

#   # it 'calls foo' do
#   #   flag = false

#   #   module MyDSL
#   #     include Gyngestol::BaseDSL

#   #     add_method :foo do ||
#   #       flag = true
#   #     end
#   #   end

#   #   class Test
#   #     include MyDSL

#   #     foo
#   #     def test
#   #     end
#   #   end

#   #   flag.should be_true
#   # end

# end
