describe Gyngestol::Endpoint, :rack do
  include Rack::Test::Methods

  before do
    class MyEndpoint
      include Gyngestol::Endpoint

      action get: '/'
      def index
        #update
        respond_with :json, {success: true}.to_json
      end

      action put: '/'
      def update
        respond_with :json, {success: true}.to_json
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
      last_response.body.should == '{"success":true}'
    end
  end

  describe 'update' do
    it "returns json" do
      put '/'

      last_response.should be_ok
      last_response.body.should == '{"success":true}'
    end
  end

end
