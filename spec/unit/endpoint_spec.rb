describe Gyngestol::Endpoint, :rack do
  include Rack::Test::Methods

  before do
    class MyEndpoint
      include Gyngestol::Endpoint

      action get: '/'
      def index
        respond_with :json, {called: 'index'}.to_json
      end

      action put: '/'
      def update
        respond_with :json, {called: 'update'}.to_json
      end
    end
  end

  def app
    Gyngestol::MountPoint.new(MyEndpoint)
  end

  describe '#index' do
    it 'returns json' do
      get '/'

      last_response.should be_ok
      last_response.body.should == '{"called":"index"}'
    end
  end

  describe 'update' do
    it "returns json" do
      put '/'

      last_response.should be_ok
      last_response.body.should == '{"called":"update"}'
    end
  end

end
