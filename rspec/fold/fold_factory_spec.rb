require 'rspec/fold_spec_helper'

class Included; include Fold::FoldFactory end

describe Fold::FoldFactory do
  it "inherits module" do
    Fold::FoldFactory.class.should == Module
  end
end

describe Fold::FoldFactory, ".count_soft_tabs" do
  before(:each) {@it= Included.new}
  
  it "counts one soft tabs" do
    @it.count_soft_tabs("  LINE").should == 1
  end
  
  it "counts tree soft tabs" do
    @it.count_soft_tabs("  " * 3 + "LINE").should == 3
  end
  
  it "raises IndentationError on odd spaced indentation" do
    lambda {
      @it.count_soft_tabs(" LINE")
    }.should raise_error(Fold::Precompiler::IndentationError)
  end
end

describe Fold::FoldFactory, ".produce" do
  before(:each) {@it= Included.new}
  
  it "folds abstractly" do
    @it.produce.is_a?(Fold::AbstractFold).should == true
  end
  
  it "folds other folds" do
    Included.folds :Location, /^\@/
    @it.produce('@LINE').is_a?(Included::Location).should == true  
  end
end



#describe Fold::Precompiler::Action::Regex do
#  it "matches !LINE" do
#    Fold::Precompiler::Action::Regex.should match("!LINE")
#  end
#end
#
#describe Fold::Precompiler::Selector::Regex do
#  it "matches ?LINE" do
#    Fold::Precompiler::Selector::Regex.should match("?LINE")
#  end
#end
#
#describe Fold::Precompiler::Group::Regex do
#  it "matches describe LINE" do
#    Fold::Precompiler::Group::Regex.should match("describe LINE")
#  end
#end
#
#describe Fold::Precompiler::Example::Regex do
#  it "matches it LINE" do
#    Fold::Precompiler::Example::Regex.should match("it LINE")
#  end
#end
