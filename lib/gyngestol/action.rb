module Gyngestol
  class Action
    include Virtus.value_object

    values do
      attribute :controller, Class
      attribute :action, Symbol
    end

    def call(app, req, args)
      controller.new(app, req).send(action, *args)
    end
  end
end
