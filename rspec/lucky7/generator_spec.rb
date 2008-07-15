require 'rspec/lucky7_spec_helper'

require "fileutils"
require "pathname"
require "tmpdir"

describe Lucky7::Generator do
  it "inherits class" do
    Lucky7::Generator.class.should == Class
  end

  describe Lucky7::Generator::SkeletonPath do
    it "is skeleton/" do
      Lucky7::Generator::SkeletonPath.should == Lucky7Root + "templates" + "skeleton"
    end
  end

  describe Lucky7::Generator::EnvironmentPath do
    it "is environment/" do
      Lucky7::Generator::EnvironmentPath.should == Lucky7Root + "templates" + "environment"
    end
  end

  describe Lucky7::Generator::TemplatePath do
    it "is templates/" do
      Lucky7::Generator::TemplatePath.should == Lucky7Root + "templates"
    end
  end

  describe Lucky7::Generator::RubySpecPath do
    it "is ruby_spec/" do
      Lucky7::Generator::RubySpecPath.should == Lucky7Root + "templates" + "ruby_spec"
    end
  end

  describe Lucky7::Generator::JavascriptSpecPath do
    it "is javascript_spec/" do
      Lucky7::Generator::JavascriptSpecPath.should == Lucky7Root + "templates" + "javascript_spec"
    end
  end

  before :each do
    @target = Pathname.new(File.join(Dir.tmpdir, "destination"))
    
    FileUtils.rm_rf(@target)
    FileUtils.mkdir(@target)

    @installer = Lucky7::Generator.new(@target)

    @mine  ||= @target + 'mine'
    @vendor||= @mine + "vendor"
    @jsspec||= @vendor + "jsspec"
    @spec  ||= @mine + "spec"
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
    end

    it "generates root" do
      (@mine).should be_exist
    end

    it "generates .lucky7 file" do
      (@mine + ".lucky7").should be_exist
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

    it "generates spec directory" do
      @spec.should be_exist
    end

    it "generates javascript spec directory" do
      (@spec + "javascript").should be_exist
    end

    it "generates ruby spec directory" do
      (@spec + "ruby").should be_exist
    end

    it "generates ruby spec helper" do
      (@spec + "ruby" + "spec_helper.rb").should be_exist
    end

    it "generates vendor directory" do
      @vendor.should be_exist
    end
    
    it "generates jsspec directory" do
      @jsspec.should be_exist
    end
  
    def should_copy file
      (@jsspec + file).should be_exist
    end 

    it "copies jsspec files to jsspec vendor dir" do
      should_copy "diff_match_patch.js"
      should_copy "JSSpec.js"
      should_copy "JSSpec.css"
    end
  end

  describe "#environment" do
    before(:each) do
      @installer.skeleton('mine')
      @installer.environment('development')
      @env = @mine + 'environment'
    end

    it "generates an environment file" do
      (@env+"development.rb").should be_exist
    end
  end

  describe "#javascript_spec" do
    before(:each) do
      @installer.skeleton('mine')
      @installer.javascript_spec('module', 'tested')
    end

    it "generates jass file" do
      (@spec + "javascript" + "jass" + "module" + "tested_spec.html.jass").should be_exist
    end
  end

  describe "#ruby_spec" do
    before(:each) do
      @installer.skeleton('mine')
      @installer.ruby_spec('module', 'tested')
    end

    it "generates spec file" do
      (@spec + "ruby" + "module" + "tested_spec.rb").should be_exist
    end
  end
end
