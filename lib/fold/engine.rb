module Fold
  class Engine
    def initialize source
      @source= source
      prepare_source
    end
    
    def prepare_source
      @prepared_source= true
    end
    
    def lines
      @source.split(/\n/).reject{|line| line.blank?}
    end
    
    def render fold= precompiler.new.fold(lines)
      fold.children.map{|child| child.render}
    end
    
#    *** me hard
    def precompiler
      @precompiler||= instance_eval "#{self.class.to_s.split(/::/).first}::Precompiler"
    end
  end
end
