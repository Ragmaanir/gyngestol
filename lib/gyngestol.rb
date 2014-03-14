require 'active_support/core_ext'
require 'virtus'

require 'pry'

module Gyngestol

  ROOT = File.join(File.dirname(__FILE__), '..')

  $LOAD_PATH.unshift(File.join(ROOT, 'lib'))

  autoload :Endpoint, 'gyngestol/endpoint'
  autoload :Escapes, 'gyngestol/escapes'
  #autoload :Routing, 'gyngestol/routing'
  autoload :DSL, 'gyngestol/dsl'

  #autoload :BaseDSL, 'gyngestol/base_dsl'
  #autoload :RoutingDSL, 'gyngestol/routing_dsl'

  module Doc
    autoload :DocGenerator,     'gyngestol/doc/doc_generator'
    autoload :HTMLDocGenerator, 'gyngestol/doc/html_doc_generator'
  end

end
