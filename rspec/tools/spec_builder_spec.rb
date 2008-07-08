require 'rspec/spec_helper'
require 'tools/spec_builder'

Lucky7::SpecBuilder.const_set :Lucky7Root, FixtureRoot

describe Lucky7::SpecBuilder do
  before(:each) {@it = Lucky7::SpecBuilder.new}

  it "inherits Builder" do
    @it.class.superclass.should == Lucky7::Builder
  end

  it "collects jass files from jspec/jass/" do
    @it.files[:Jass].should == Dir.glob("#{FixtureRoot}/jspec/jass/**/*.html.jass")
  end

  it "takes /jass out of build path" do
    path = @it.build_path_for("#{FixtureRoot}/jspec/jass/file.html.jass")
    path.should_not include("/jass")
  end

  it "builds in jspec/" do
    @it.build_all
    built = Pathname.new(FixtureRoot) + "jspec" + "faux_spec.html"
    built.should be_exist
    FileUtils.rm_f built
  end
end