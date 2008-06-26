module Fold
  module FoldFactory
    Indent= 2
    class IndentationError < StandardError; end
    
    def self.included klass
      klass.extend ClassMethods
    end
    
    def produce line=''
      tabs = count_soft_tabs(line)
      line = line.sub(/^[ ]+/, '')
      attrs= {
        :text => line, 
        :tabs => tabs
      }
    
      if klass= detect_class(line)
        klass.new attrs
      else
        AbstractFold.new attrs.merge(:tabs => -1)
      end
    end
    
    def detect_class line
      return nil if line.blank?
      self.class.defined_folds.reverse.detect {|fold| fold::Regex and fold::Regex.match(line)}
    end
    
    def count_soft_tabs line
      spaces= line.index(/([^ ]|$)/)
      raise IndentationError if spaces.odd?
      spaces / Indent
    end
    
    module ClassMethods
      def folds id, regex=AbstractFold::Regex, &block
        fold= Class.new(AbstractFold)
        fold.const_set :Regex, regex
        
        fold.send :define_method, :render, &block if block_given?
        
        const_set id, fold
        defined_folds << fold
      end
      
      def defined_folds
        @folds||= []
      end
    end
  end
end