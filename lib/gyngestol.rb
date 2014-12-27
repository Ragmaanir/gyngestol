require 'active_support'
require 'active_support/core_ext'
require 'virtus'
require 'rack'

require 'pry'

module Gyngestol

  ROOT = File.join(File.dirname(__FILE__), '..')

  $LOAD_PATH.unshift(File.join(ROOT, 'lib'))

  autoload :Router, 'gyngestol/router'
  autoload :RouteMatcher, 'gyngestol/router'
  autoload :RoutingDSL, 'gyngestol/routing_dsl'
  autoload :RouterBuilder, 'gyngestol/router_builder'

  autoload :MountPoint, 'gyngestol/mount_point'
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
