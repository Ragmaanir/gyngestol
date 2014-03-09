require ::File.expand_path('../../../lib/gyngestol',  __FILE__)

class SimpleServer
  include Gyngestol::Endpoint

  action get: '/'
  def index
    respond_with :json, "Index: #{Time.now}"
  end

  action get: '/status'
  def show
    respond_with :json, "Show: #{Time.now}"
  end

end
