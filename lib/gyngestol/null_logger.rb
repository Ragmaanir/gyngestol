module Gyngestol
  class NullLogger < Logger
    def initialize(*args)
    end

    def add(*args, &block)
    end
  end
end
