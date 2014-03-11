describe Gyngestol do

  class MyEndpoint
    include Gyngestol::Endpoint

    describe 'Returns the current time'
    action get: '/'
    def index
      respond_with :json, Time.now
    end
  end

end
