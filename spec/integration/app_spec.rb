describe Gyngestol::App, type: :integration do
  include Rack::Test::Methods

  let(:app) do
    Gyngestol::App.new(router: router)
  end

  context '' do

    let(:router) do
      router = Gyngestol::RouterBuilder.build(Gyngestol::Router, Object) do
        namespace 'users' do
          path :int do
            action :get, :show
          end
        end
      end
    end

    it '' do
      class User
        def initialize(env)
        end

        def show(id)
          id
        end
      end

      get '/users/1337'
      assert{ last_response.status == 200 }

      get '/users/1337/'
      assert{ last_response.status == 200 }

      get '/users'
      assert { last_response.status == 404 }
    end

  end

end
