require 'rspec/lucky7_spec_helper'

require "fileutils"
require "pathname"
require "tmpdir"

describe Lucky7::Generator do
  it "inherits class" do
    Lucky7::Generator.class.should == Class
  end

  describe Lucky7::Generator::SkeletonPath do
    it "is /skeleton" do
      Lucky7::Generator::SkeletonPath.should == "#{Lucky7Root}/templates/skeleton"
    end
  end

  describe Lucky7::Generator::EnvironmentPath do
    it "is /environment" do
      Lucky7::Generator::EnvironmentPath.should == "#{Lucky7Root}/templates/environment"
    end
  end

  describe Lucky7::Generator::TemplatePath do
    it "is /templates" do
      Lucky7::Generator::TemplatePath.should == "#{Lucky7Root}/templates"
    end
  end

  before :each do
    @target = Pathname.new(File.join(Dir.tmpdir, "destination"))
    
    FileUtils.rm_rf(@target)
    FileUtils.mkdir(@target)

    @installer = Lucky7::Generator.new(@target)
  end 

  describe "#install_to_path" do
    it "does the basis/installer thing" do
      sample = Pathname.new(File.join(Dir.tmpdir, 'magic'))
      FileUtils.rm_rf sample
      FileUtils.mkdir sample
      FileUtils.mkdir sample + "world"
      FileUtils.touch sample + "world" + "cool.txt"
      @installer.install_to_path sample
      (@target+"world").should be_exist
    end
  end

  describe "#initialize" do
    it "initializes sanely" do
      @installer.root.should == @target
    end
  end

  describe "#skeleton" do
    before(:each) do
      @installer.skeleton('mine')
      @mine = @target + 'mine'
    end

    it "generates root" do
      (@mine).should be_exist
    end

    it "generates rakefile" do
      (@mine+"Rakefile.rb").should be_exist
    end

    it "generates README" do
      (@mine+"README").should be_exist
    end

    it "generates environment" do
      (@mine+"environment").should be_exist
    end

    it "generates environment.rb" do
      (@mine+"environment"+"environment.rb").should be_exist
    end
  end

  describe "#environment" do
    before(:each) do
      @installer.skeleton('mine')
      @installer.environment('development')
      @env = @target + 'environment'
    end

    it "generates an environment file" do
      (@env+"development.rb").should be_exist
    end
  end
end
