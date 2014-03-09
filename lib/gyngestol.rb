require 'active_support/core_ext'
require 'virtus'

require 'pry'

module Gyngestol

  ROOT = File.join(File.dirname(__FILE__), '..')

  $LOAD_PATH.unshift(File.join(ROOT, 'lib'))

  autoload :Endpoint, 'gyngestol/endpoint'
  autoload :Escapes, 'gyngestol/escapes'

end
