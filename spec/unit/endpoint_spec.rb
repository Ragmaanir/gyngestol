describe Gyngestol::Endpoint, :rack do
  include Rack::Test::Methods

  before do
    class MyEndpoint
      include Gyngestol::Endpoint

      action get: '/'
      def index
        respond_with :json, {success: true}.to_json
      end

      action put: '/'
      def update
      end
    end
  end

  def app
    Rack::Builder.new do
      run MyEndpoint
    end
  end

  describe '#index' do
    it 'returns json' do
      get '/'

      last_response.should be_ok
      last_response.body.should == '{"success":true}'
    end
  end

end
