require 'rspec/lucky7_spec_helper'

describe Lucky7 do
  it "inherits Module" do
    Lucky7.class.should == Module
  end
  
  it "has a Builder Module" do
    Lucky7.constants.should include("Builder")
  end
  
  it "has a Renders Module" do
    Lucky7.constants.should include("Renders")
  end
end