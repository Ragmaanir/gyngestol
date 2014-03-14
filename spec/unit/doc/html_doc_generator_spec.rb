describe Gyngestol::Doc::HTMLDocGenerator do

  before do
    class B
      include Gyngestol::DSL

      describe 'The index action'
      action get: '/'
      def index
      end
    end
  end

  let(:doc) { described_class.new.generate(B) }

  it 'generate markdown' do
    doc.should match(/<h2>\s*Action:/)
    doc.should match(%r{:get=>"/"})
    doc.should match(%r{index})
  end

end
