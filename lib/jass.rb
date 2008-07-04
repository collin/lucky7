require 'haml'

module Jass
  class Precompiler < Fold::Precompiler
    folds :Line, // do
      "\n#{(" "*Indent*tabs)+text}#{render_children}"
    end

    folds :ExampleGroup, /^describe / do
      "describe(\"#{text}\", {\n  #{render_children.join('  ,')}});\n\n"
    end

    folds :Example,      /^it / do
      "\"#{text}\": function() {#{render_children.map{|child|"#{child}"}}\n  }\n"
    end
  end
  
  class Engine < Fold::Engine
    Layout= Haml::Engine.new File.read("#{Lucky7Root}/lib/jsspec/layout.html.haml")
    
    def render context=nil
      Layout.render Object.new, {:test=>super}    
    end
  end
end
