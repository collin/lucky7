require 'rspec/spec_helper'

describe Jass do
  it "inherits Module" do
    Jass.class.should == Module
  end
  
  it "has an Engine Class" do
    Jass.constants.should include("Engine")
  end
  
  it "has a precompiler class" do
    Jass.constants.should include("Precompiler")
  end
end
