require "ostruct"
require 'rspec/fold_spec_helper'

describe Fold::AbstractFold do
  it "inherits OpenStruct" do
    Fold::AbstractFold.superclass.should == OpenStruct
  end
end

describe Fold::AbstractFold, ".initialize" do
  it "and sets the regex" do
    Fold::Precompiler.folds :What, /what/
    Fold::Precompiler::What::Regex.should == /what/
  end
end

describe Fold::AbstractFold, ".render" do
  it "renders cleanly" do
    fold= Fold::AbstractFold.new(:text=>"LINE")
    fold.render.should == "LINE"
  end
  
  it "renders from block" do
    Fold::Precompiler.folds :What, /what/ do
      "#{text}?"
    end
    
    what= Fold::Precompiler::What.new(:text=>'whatever')
    what.render.should== "ever?"
  end
  
  it "renders children" do
    Fold::Precompiler.folds :Parent, /^parent / do
      "Hey, #{text} here, my children are: #{render_children.join(', ')}"
    end

    Fold::Precompiler.folds :Child, /^child /
    
    will= Fold::Precompiler::Parent.new(:text=>"Will")
    will.children << Fold::Precompiler::Child.new(:text=>"Tony")
    will.children << Fold::Precompiler::Child.new(:text=>"Ace")
    
    will.render.should == "Hey, Will here, my children are: Tony, Ace"
  end
end

describe Fold::AbstractFold, ".render_children" do
  it "renders cleanly" do
    Fold::Precompiler.folds :Parent, /^parent /
    Fold::Precompiler.folds :Child, /^child /
    
    will= Fold::Precompiler::Parent.new(:text=>"Will")
    will.children << Fold::Precompiler::Child.new(:text=>"Tony")
    will.children << Fold::Precompiler::Child.new(:text=>"Ace")
    
    will.render_children.should == ["Tony", "Ace"]
  end 
end