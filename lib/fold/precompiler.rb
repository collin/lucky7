module Fold
  class Precompiler
    include Fold::FoldFactory
  
    def fold lines
      last_line= produce

      parent_line= nil
      
      parent_stack= []

      lines.each do |text|
        line = produce text

        indent = line.tabs - last_line.tabs

        raise IndentationError if indent > 1 
        
        if step_in? indent
          parent_line = last_line
          parent_line.children << line
          parent_stack << parent_line
        end
      
        if step_aside? indent
          parent_line.children << line 
        end
        
        if step_out? indent
          parent_stack= parent_stack.slice 0, parent_stack.length + indent
          parent_line = parent_stack.last
          parent_line.children << line
        end
     
        last_line= line
      end
      parent_stack.first
    end
    
    def step_in? indent
      indent == 1
    end
    
    def step_out? indent
      indent < 0
    end
    
    def step_aside? indent
      indent == 0
    end
  end
end
