require 'haml'

module Jass
  class Precompiler < Fold::Precompiler
    include Johnson::Nodes
    JsSpecRoot = Lucky7Root + "vendor" + "js_spec"

    attr_accessor :scripts
  
    def initialize
      super
      
      @scripts = []
      @scripts << JsSpecRoot + "diff_match_patch.js"
      @scripts << JsSpecRoot + "JSSpec.js"
      @scripts << Lucky7Root + "vendor" + "jquery" + "jquery-1.2.6.js"
    end

    folds :Line, // do
      children.inject(text) do |script, child|
        "#{script}#{child.text}#{child.render_children}"
      end
    end

    folds :ExampleGroup, /^describe / do
      call = FunctionCall.new(0,0)
      call << Name.new(0,0, 'describe')
      call << String.new(0,0, text)
      call << ObjectLiteral.new(0,0, render_children)
      call
    end

    folds :Example,      /^it / do
      js = render_children.join

      Property.new(0,0, String.new(0,0, text),
        Function.new(0,0, nil, [], Johnson::Parser.parse(js)))
    end

    folds :Require,      /^require / do
      @scripts << eval(text)
      ""
    end
  end
  
  class Engine < Fold::Engine
    template = Lucky7Root + "lib" + "jsspec" + "layout.html.haml"
    Layout= Haml::Engine.new(template.read)
    
    def render context=nil
      @p = precompiler_class.new
      value = @p.fold(lines).children.map{|child| child.render}
      sexp = Johnson::Nodes::SourceElements.new(0,0)

      value.each{|line| sexp << line unless line.blank?}

      Layout.render Object.new, {
        :test => sexp.to_ecma, 
        :scripts => @p.scripts
      }    
    end
  end
end
