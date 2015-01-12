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
            get :show
            put :update
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

        def update(id)
          id
        end
      end

      get '/users/1337'
      assert{ last_response.status == 200 }
      assert{ last_response.body == "1337" }

      get '/users/1/'
      assert{ last_response.status == 200 }
      assert{ last_response.body == "1" }

      get '/users'
      assert { last_response.status == 404 }

      put '/users/123'
      assert{ last_response.status == 200 }
      assert{ last_response.body == '123' }
    end

  end

end
