require 'rspec/fold_spec_helper'

describe Fold do
  it "inherits Module" do
    Fold.class.should == Module
  end
  
  it "has an Engine Class" do
    Fold.constants.should include("Engine")
  end
  
  it "has a precompiler class" do
    Fold.constants.should include("Precompiler")
  end
end
