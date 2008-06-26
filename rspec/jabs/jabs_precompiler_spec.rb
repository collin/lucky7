require 'rspec/jabs_spec_helper'

describe Jabs::Precompiler, ".defined_folds" do
  it "defines Line" do
    Jabs::Precompiler.defined_folds.should include(Jabs::Precompiler::Line)
  end
  
  it "defines Action" do
    Jabs::Precompiler.defined_folds.should include(Jabs::Precompiler::Action)
  end
  
  it "defines Selector" do
    Jabs::Precompiler.defined_folds.should include(Jabs::Precompiler::Selector)
  end
end

describe Jabs::Precompiler, ".produce" do
  before(:each) {@it= Jabs::Precompiler.new}
  
  it "produces Lines" do
    @it.produce('LINE').is_a?(Jabs::Precompiler::Line).should == true
  end
  
  it "produces Actions" do
    @it.produce('!LINE').is_a?(Jabs::Precompiler::Action).should == true
  end
  
  it "produces Selectors" do
    @it.produce('?LINE').is_a?(Jabs::Precompiler::Selector).should == true
  end
end

describe Jabs::Precompiler::Line::Regex do
  it "should match anything" do
    Jabs::Precompiler::Line::Regex.should match('anything')
  end
end

describe Jabs::Precompiler::Action::Regex do
  it "should match !actions" do
    Jabs::Precompiler::Action::Regex.should match("!actions")
  end
end

describe Jabs::Precompiler::Selector::Regex do
  it "should match ?selectors" do
    Jabs::Precompiler::Selector::Regex.should match("?selectors")
  end
end

