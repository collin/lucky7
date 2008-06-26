require 'haml'

module Jass
  class Precompiler < Fold::Precompiler
    folds :Line, // 

    folds :ExampleGroup, /^describe / do
      "describe(\"#{text}\", {\n  #{render_children.join('  ,')}});\n\n"
    end

    folds :Example,      /^it / do
      "\"#{text}\": function() {\n  #{render_children}\n  }\n"
    end
  end
  
  class Engine < Fold::Engine
    Layout= Haml::Engine.new File.read("#{Lucky7Root}/lib/jsspec/layout.html.haml")
    
    def render
      Layout.render Object.new, {:test=>super}    
    end
  end
end
