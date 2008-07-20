require 'rspec/jabs_spec_helper'

describe Jabs::Precompiler do
  before(:each) do
    @p = Jabs::Precompiler.new
  end

  describe "initializes sanely" do
    it "has templates hash" do
      @p.templates === {}
    end

    it "has actions hash" do
      @p.actions === {}
    end

    it "has selectors hash" do
      @p.selectors === {}
    end
  end

  it "folds selectors" do
    @p.fold(["?named div > a.whatever"]).render_children
    @p.selectors["named"].should == "div > a.whatever"
  end

  it "folds actions" do
    @p.fold(["!click one, two, three"]).render_children
    @p.actions["click"].first[:selectors].should == %w{one two three}
  end

  it "folds multiple selectors for action" do
    @p.fold(["!click one, two, three"]).render_children
    @p.fold(["!click one, two, three"]).render_children
    @p.actions["click"].length.should == 2
  end

  it "folds class" do
    @p.fold(["class Klass"]).render_children
    @p.klass.should == "Klass"
  end

  it "raises error if klass specified twice" do
    proc {
      @p.fold(["class Klass","class Klass"]).render_children
    }.should raise_error
  end
end
