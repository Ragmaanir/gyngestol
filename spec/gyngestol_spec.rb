describe Gyngestol do

  before do
    class MyEndpoint
      include Gyngestol::Endpoint

      describe 'Returns the current time'
      action get: '/'
      def index
        respond_with :json, Time.now
      end
    end
  end

  it 'succeeds' do
  end

end
