require 'rspec/spec_helper'

describe Jass::Precompiler, ".defined_folds" do
  it "defines Line" do
    Jass::Precompiler.defined_folds.should include(Jass::Precompiler::Line)
  end
  
  it "defines Action" do
    Jass::Precompiler.defined_folds.should include(Jass::Precompiler::ExampleGroup)
  end
  
  it "defines Selector" do
    Jass::Precompiler.defined_folds.should include(Jass::Precompiler::Example)
  end
end

describe Jass::Precompiler, ".produce" do
  before(:each) {@it= Jass::Precompiler.new}
  
  it "produces Lines" do
    @it.produce('LINE').is_a?(Jass::Precompiler::Line).should == true
  end
  
  it "produces ExampleGroups" do
    @it.produce('describe LINE').is_a?(Jass::Precompiler::ExampleGroup).should == true
  end
  
  it "produces Examples" do
    @it.produce('it LINE').is_a?(Jass::Precompiler::Example).should == true
  end
end

describe Jass::Precompiler::Line::Regex do
  it "should match anything" do
    Jass::Precompiler::Line::Regex.should match('anything')
  end
end

describe Jass::Precompiler::ExampleGroup::Regex do
  it "should match example groups" do
    Jass::Precompiler::ExampleGroup::Regex.should match("describe Something!")
  end
end

describe Jass::Precompiler::Example::Regex do
  it "should match examples" do
    Jass::Precompiler::Example::Regex.should match("it behaves thusly")
  end
end
