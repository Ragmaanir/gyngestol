describe Gyngestol::App, type: :integration do
  include Rack::Test::Methods

  context '' do

    let(:app) do
      Gyngestol::App.new(router: router)
    end

    let(:router) do
      router = Gyngestol::RouterBuilder.build(Gyngestol::Router, Object) do
        namespace 'users' do
          get :index

          path :int do
            get :show
            put :update
          end
        end
      end
    end

    it '' do
      class User
        include Gyngestol::Endpoint

        def index
          redirect_to('/')
        end

        def show(id)
          {id: id}
        end

        def update(id)
          {id: id}
        end
      end

      get '/users/1337'
      assert{ last_response.status == 200 }
      assert{ last_response.body == JSON.generate(id: 1337) }

      get '/users/1/'
      assert{ last_response.status == 200 }
      assert{ last_response.body == JSON.generate(id: 1) }

      put '/users/123'
      assert{ last_response.status == 200 }
      assert{ last_response.body == JSON.generate(id: 123) }

      get '/users'
      assert{ last_response.status == 302 }

      post '/users'
      assert { last_response.status == 404 }
    end

  end

  context '' do

    let(:app) do
      Gyngestol::App.new(router: router, config: config)
    end

    let(:config) do
      Gyngestol::Configuration.new do |c|
      end
    end

    let(:router) do
      router = Gyngestol::RouterBuilder.build(Gyngestol::Router, Object) do
        namespace 'users' do
          path :int do
            get :show
          end
        end
      end
    end

    it '' do
      class User
        include Gyngestol::Endpoint

        def show(id)
          'test'
        end
      end

      get '/users/1337'
      assert{ last_response.status == 500 }
      assert{ last_response.body == "Internal Server Error" }
    end

  end

end
