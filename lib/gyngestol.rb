require 'active_support'
require 'active_support/core_ext'
require 'virtus'
require 'rack'

require 'pry'

module Gyngestol

  ROOT = File.join(File.dirname(__FILE__), '..')

  $LOAD_PATH.unshift(File.join(ROOT, 'lib'))

  autoload :App, 'gyngestol/app'
  autoload :Action, 'gyngestol/terminal_node'
  autoload :Router, 'gyngestol/router'
  autoload :RouteMatcher, 'gyngestol/router'
  autoload :RoutingDSL, 'gyngestol/routing_dsl'
  autoload :RouterBuilder, 'gyngestol/router_builder'
  autoload :Node, 'gyngestol/node'
  autoload :InnerNode, 'gyngestol/inner_node'
  autoload :TerminalNode, 'gyngestol/terminal_node'

  autoload :MountPoint, 'gyngestol/mount_point'
  autoload :Endpoint, 'gyngestol/endpoint'
  autoload :Escapes, 'gyngestol/escapes'
  autoload :DSL, 'gyngestol/dsl'

  module Doc
    autoload :DocGenerator,     'gyngestol/doc/doc_generator'
    autoload :HTMLDocGenerator, 'gyngestol/doc/html_doc_generator'
  end

end
