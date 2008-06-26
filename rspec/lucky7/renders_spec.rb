require 'rspec/lucky7_spec_helper'

describe Lucky7::Renders, ".render" do
  it "renders collection js template code" do
    code= Renders.render :template, :object
    code.should == "={\"template\":object}"
  end
  
  it "renders inline js template" do
    code= Lucky7::Renders.render :template
    code.should == "={\"template\":__context}"
  end
end