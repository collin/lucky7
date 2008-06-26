require 'rspec/fold_spec_helper'

describe Fold::Engine do
  it "inherits Module" do
    Fold::Engine.class.should == Class
  end
end

describe Fold::Engine, ".initialize" do
  before(:each) do
    @path= "#{FoldFixtureRoot}/fixture.target.fold"
    @engine= Fold::Engine.new File.read(@path)  
  end

  it "sets fold content" do
    @engine.instance_variable_get(:@source).should == File.read(@path)
  end
end

describe Fold::Engine, ".prepare_fold" do
  before(:each) do
    @path= "#{FoldFixtureRoot}/fixture.target.fold"
    @engine= Fold::Engine.new File.read(@path)  
  end
  
  it "prepares fold content" do
    @engine.instance_variable_get(:@prepared_source).should_not be_nil
  end
end

describe Fold::Engine, ".lines" do
  it "splits on line breaks" do
    lines= 10
    src= "LINE\n" * lines
    en= Fold::Engine.new src
    en.lines.length.should == lines
  end
  
  it "rejects whitespace only lines" do
    src= "LINE\n   \nLINE\n\t\n\t\nwhatup?"
    en= Fold::Engine.new src
    en.lines.length.should == 3
  end
end

describe Fold::Engine, ".render" do
  it "renders spec" do
    Fold::Precompiler.folds :Line, //
    source= File.read "#{FoldFixtureRoot}/fixture.target.fold"
    en= Fold::Engine.new source
    pp en.render
  end
end