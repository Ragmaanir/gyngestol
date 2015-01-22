require 'active_support'
require 'active_support/core_ext'
require 'virtus'
require 'ice_nine'
require 'rack'

module Gyngestol

  autoload :App,            'gyngestol/app'
  autoload :Action,         'gyngestol/action'
  autoload :Configuration,  'gyngestol/configuration'
  autoload :NullLogger,     'gyngestol/null_logger'
  autoload :Route,          'gyngestol/route'
  autoload :Router,         'gyngestol/router'
  autoload :RoutingDSL,     'gyngestol/routing_dsl'
  autoload :RouterBuilder,  'gyngestol/router_builder'
  autoload :Node,           'gyngestol/node'
  autoload :HttpUtils,      'gyngestol/http_utils'
  autoload :InnerNode,      'gyngestol/inner_node'
  autoload :TerminalNode,   'gyngestol/terminal_node'

  autoload :Endpoint,       'gyngestol/endpoint'
  autoload :Escapes,        'gyngestol/escapes'
  autoload :DSL,            'gyngestol/dsl'

  #module Doc
  #  autoload :DocGenerator,     'gyngestol/doc/doc_generator'
  #  autoload :HTMLDocGenerator, 'gyngestol/doc/html_doc_generator'
  #end

end
