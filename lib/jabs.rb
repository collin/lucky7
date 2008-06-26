module Jabs
  class Precompiler < Fold::Precompiler
    folds :Line, //
    folds :Action, /^\!/
    folds :Selector, /^\?/
  end
  
  class Engine < Fold::Engine; end
end