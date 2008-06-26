require 'rspec/fold_spec_helper'

describe Fold::Precompiler do
  it "inherits module" do
    Fold::Precompiler.class.should == Class
  end
end

class Confused < Fold::Precompiler
  folds :Line, //
  folds :What, /what/
end  

describe Fold::Precompiler, ".folds" do
  it "generates AbstractFold subclasses" do
    Confused::What.superclass.should == Fold::AbstractFold
  end
  
  it "in the appropriate namespace" do
    Confused::What.should_not be_nil
  end
  
  it "pushes to defined_folds" do
    Confused.defined_folds.should include(Confused::What)
  end
end

describe Fold::Precompiler, ".fold" do
  before(:each) do
    @it= Confused.new
  end
  
  it "has notion of top level" do
    en= Fold::Engine.new %{
LINE 1
  LINE 2
  LINE 3
LINE 4
  LINE 5
  LINE 6
  
LINE 7
  LINE 8
    LINE 9
    }
    @it.fold(en.lines).children.length.should == 3
  end
  
  it "barfs on innappropriate indentation" do
    en= Fold::Engine.new %{
LINE 1
    LINE 2
    }
    lambda {
      @it.fold(en.lines)
    }.should raise_error(Confused::IndentationError)
  end
end

describe Fold::Precompiler, ".step_in?" do
  before(:each) do
    @it= Confused.new
  end
  
  it "must indent 1" do
    @it.step_in?(1).should == true
  end

  it "no more" do
    @it.step_in?(2).should == false
  end
  
  it "no less" do
    @it.step_in?(0).should == false
  end
end

describe Fold::Precompiler, ".step_out?" do
  before(:each) do
    @it= Confused.new
  end
  
  it "must indent < 0" do
    @it.step_out?(-1).should == true
  end
  
  it "cannot indent > 0" do
    @it.step_out?(0).should == false
  end
end

describe Fold::Precompiler, ".step_aside?" do
  before(:each) do
    @it= Confused.new
  end
  
  it "must indent 0" do
    @it.step_aside?(0).should == true
  end

  it "no more" do
    @it.step_aside?(1).should == false
  end
  
  it "no less" do
    @it.step_aside?(-1).should == false
  end
end