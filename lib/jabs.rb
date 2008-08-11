require 'haml'
require 'johnson'
require 'pathname'

__DIR__ = Pathname.new(__FILE__).dirname
$LOAD_PATH << __DIR__ unless $LOAD_PATH.include?(__DIR__)

module Jabs
  include Johnson::Nodes

  class Precompiler < Fold::Precompiler
    attr_accessor :klass, :souper, :templates, :selectors, :actions

    def initialize
      super
      
# unallocated instance variables don't show up
      @klass = ""

      @templates = {}
      @selectors = {}
      @actions   = {}
    end

    folds :Line, // do
      children.inject(text) do |source, child|
        "#{source}\n#{' ' * (Indent * tabs)}#{child.render}"
      end
    end

    folds :Selector, /^\?/ do
      self.text = text.split(/ /)
      name = text.shift
      selectors[name] = text.join(' ')
    end

    folds :Action, /^\!/ do
      self.text = text.gsub(',', ' ').split(' ')
      js = Johnson::Parser.parse(render_children.join)
      name = text.shift
      actions[name]||= [] 
      actions[name] << {
        :javascript => js,
        :selectors  => text
      }
    end

    folds :Class, /^class / do
      raise "Cannot specify two classes!" unless klass.empty?
      self.klass << text
    end

    folds :Template, /^:/ do
      en = Haml::Engine.new(render_children.join("\n"))
      templates[text] = en.render
    end
  end
  
  class Engine < Fold::Engine

    def render
      @p = precompiler_class.new
      value = @p.fold(lines).children.map{|child| child.render}
      sexp = johnsonize [:source_elements]
      sexp << klass
      sexp << templates
      sexp << actions
      sexp.to_ecma
    end

    def johnsonize(sexp)
      return sexp if sexp.is_a?(Johnson::Nodes::Node)
      return sexp if sexp.class.to_s == "String"
      return [] if sexp === []
      return nil if sexp === nil
      unless sexp.first.class.to_s == "Array"
        if sexp.first.class.to_s == "Symbol"
          eval("Johnson::Nodes::#{sexp.shift.to_s.camelcase}").new 0,0, *sexp.map{|n|johnsonize(n)}
        else
          sexp
        end
      else
        sexp.map{|n|johnsonize(n)}
      end
    end  

    def klass
      var = johnsonize [:var_statement]
      var << johnsonize([:assign_expr, 
        [:name, @p.klass],
        [:object_literal, [
#           [:property, 
#             [:name, 'templates'],
#             [:object_literal]
#           ]
        ]]
      ])
      var
    end

    def extend mod, properties
      johnsonize [:function_call, [ 
        [:dot_accessor,
          [:name, 'extend'],
          [:name, 'jQuery']],
        [:dot_accessor,
          [:name, mod],
          [:name, @p.klass]],
        [:object_literal,
          properties
        ]
      ]]
    end

    def templates
      @p.templates.map do |key, value|
        johnsonize [:function_call, [
          [:dot_accessor,
            [:name, 'Template'],
            [:name, 'Lucky7']
          ],
          [:string, key],
          [:string, value]
        ]]
      end.first
#       extend('templates', @p.templates.map{|key,value|
#          [:property, 
#           [:name, key],
#           [:string, value]
#         ]
#       })
    end

    def jquery_bind bind_to=[], *bind_args
      [:function_call, [
        [:dot_accessor,
          [:name, 'bind'],
          jquery(*bind_to)
        ],
        *bind_args
      ]]
    end

    def jquery *jquery_arg
      [:function_call, [
        [:name, 'jQuery'],
        jquery_arg
      ]]
    end

    def actions
      johnsonize jquery_bind([:name, 'document'],
        [:string, 'ready'],
        [:function, nil, [], [:source_elements, [
          jquery_bind([:string, ".#{@p.klass}"],
            [:object_literal,
              @p.actions.map do |action, segments|
                [:property, 
                  [:string, action],
                  [:function, nil, ['event'], 
                    [:source_elements,
                      ([[:var_statement, [
                        [:assign_expr,
                          [:name, 'el'],
                          [:function_call, [
                            [:name, 'jQuery'],
                            [:dot_accessor,
                              [:name, 'target'],
                              [:name, 'event']
                            ]
                          ]]
                        ]
                      ]]] +
                      segments.map do |segment|
                        [:if,
                          [:function_call, [
                            [:dot_accessor, 
                              [:name, 'is'],
                              [:name, "el"]
                            ],
                            [:string, segment[:selectors].map{|s| @p.selectors[s]}.join(', ')],
                          ]],
                          segment[:javascript],
                          nil
                        ]
                      end)
                    ]
                  ]
                ]
              end
            ])
      ]]])
    end
  end
end
