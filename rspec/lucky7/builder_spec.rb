require 'rspec/lucky7_spec_helper'

include Lucky7
    
Builder.const_set :Lucky7Root, FixtureRoot

HamlRegex= /html\.haml/
SassRegex= /css\.sass/
JabsRegex= /\.js/
SpecRegex= /html\.jass/
FixtureRegex= /fixtures/

def modify_file! file="#{Builder::Lucky7Root}/src/app/layout.html.haml"
  stamp = File.mtime(file) + 5000
  command = File.utime(stamp, stamp, file)
end

describe modify_file! do
  it "sends a file into the future" do
    file = "#{Builder::Lucky7Root}/src/app/layout.html.haml"
    past = File.mtime(file)
    File.stat(file).mtime.should >= past
  end
end


describe Builder do
  it "inherits Class" do
    Builder.class.should == Class
  end

  describe Lucky7Root do
    it "is a fixture" do
      Builder::Lucky7Root.match(FixtureRegex).should_not == nil
    end
  end

  before(:each) {@builder = Builder.new}

  describe "#build" do
    before(:each) do
      @builder.cache_mtimes!
    end
  
    it "builds spec files" do
      @builder.should_receive(:build_spec).once
      @builder.build
    end
  
    it "builds haml files" do
      @builder.should_receive(:build_haml).once
      @builder.build
    end
    
    it "builds sass files" do
      @builder.should_receive(:build_sass).once
      @builder.build
    end
    
    it "builds jabs files" do
      @builder.should_receive(:build_jabs).once
      @builder.build
    end
    
    it "packs" do
      @builder.should_receive(:pack).once
      @builder.build
    end
  end

  describe "#build_path_for" do  
    it "constructs a build path" do
      @builder.build_path_for(:extension, "#{Lucky7Root}/src/some_file.extension_.processor").should == "#{Lucky7Root}/build/some_file.extension"
    end
    
    it "maintains path depth" do
      @builder.build_path_for(:extension, "#{Lucky7Root}/src/place/some_file.extension_.processor").should == "#{Lucky7Root}/build/place/some_file.extension"
    end
    
    it "builds multi dot files" do
      @builder.build_path_for("spec.html", "#{Lucky7Root}/src/place/some_file.extension.processor").should == "#{Lucky7Root}/build/place/some_file.spec.html"
    end
  end

  describe "#files" do
    it "contains haml files" do
      @builder.files[:haml].should_not be_empty
    end
    
    it "contains jabs files" do
      @builder.files[:jabs].should_not be_empty
    end
    
    it "contains sass files" do
      @builder.files[:sass].should_not be_empty
    end
    
    it "contains spec files" do
      @builder.files[:spec].should_not be_empty
    end
  end
  
  describe "#files_flattened" do
    it "returns an array" do
      @builder.files_flattened.class.should == Array
    end
    
    it "is flat" do
      files = @builder.files_flattened
      files.should == files.flatten
    end
  end

  describe "#mtimes" do
    it "returns a hash" do
      @builder.mtimes.class.should == Hash
    end
  
    it "keys are filenames" do
      @builder.mtimes.reject{|key, value| File.exists? key}.should be_empty
    end
  
    it "values are Times" do
      @builder.mtimes.reject{|key, value| value.is_a? Time}.should be_empty
    end
  end

  describe "#build_haml" do
    before(:each) do
      @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.html.haml"
      @build_glob= "#{Builder::Lucky7Root}/build/app/*.html"
      build= Dir.glob @build_glob
      FileUtils.rm build, :force => true
    end
    
    it "renders html documents" do
      @builder.build_haml(@src)
      Dir.glob(@build_glob).length.should == @src.length  
    end
  end
  
  describe "#build_sass" do
    before(:each) do
      @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.css.sass"
      @build_glob= "#{Builder::Lucky7Root}/build/app/*.css"
      build= Dir.glob @build_glob
      FileUtils.rm build, :force => true
    end
    
    it "renders css files" do
      @builder.build_sass(@src)
      Dir.glob(@build_glob).length.should == @src.length  
    end
  end
  
  describe "#build_spec" do
    before(:each) do
      @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.spec.yaml"
      @build_glob= "#{Builder::Lucky7Root}/build/app/*.spec.html"
      build= Dir.glob @build_glob
      FileUtils.rm build, :force => true
    end
    
    it "renders jsspec files" do
      @builder.build_spec(@src)
      Dir.glob(@build_glob).length.should == @src.length  
    end
  end
  
  describe "#haml_render_context" do
    it "is Lucky7::Renders" do
      @builder.haml_render_context.should == Lucky7::Renders
    end
  end
  
  describe "#modified_files" do
    before(:each) do
      @builder.cache_mtimes!
    end
  
    it "returns a Hash" do
      @builder.modified_files.class.should == Hash
    end
  
    it "contains modified files names" do
      modify_file!
      @builder.modified_files[:haml].should_not be_empty
    end
  
    it "ignores unmodified files" do
      @builder.modified_files[:haml].should be_empty
    end
  
    it "contains new files" do
      file = "#{Builder::Lucky7Root}/src/app/touche.js.jabs"
      FileUtils.touch(file)
      @builder.modified_files[:jabs].should include(file)
      FileUtils.rm(file)
    end
  end
  
  describe "#cache_mtimes!" do
    it "caches_mtimes" do
      @builder.cache_mtimes!
      @builder.instance_variable_get(:@cached_mtimes).should == @builder.mtimes
    end
  end
  
  describe "#cached_mtimes" do
    before(:each) do
      @builder.cache_mtimes!
    end
  
    it "returns a hash" do 
      @builder.cached_mtimes.class.should == Hash
    end
  
    it "same as mtimes if no change" do
      @builder.cached_mtimes.should == @builder.mtimes
    end
  
    it "holds old mtimes" do
      modify_file!
      @builder.cached_mtimes.should_not == @builder.mtimes
    end
  end
  
  describe "#ensure_build_path!" do
    it "makes all parent dirs" do
      @builder.ensure_build_path! "#{Builder::Lucky7Root}/build/app/layout.html.haml"
      File.exists?("#{Builder::Lucky7Root}/build/app/").should == true
      FileUtils.rm_rf "#{Builder::Lucky7Root}/build/app"
    end
  end
  
  describe "#build_continuously" do
    it "caches mtimes" do
      @builder.build_continuously false
      @builder.instance_variable_get(:@cached_mtimes).should_not be_nil
    end
  
    it "builds" do 
      @builder.should_receive(:build).once
      @builder.build_continuously false
    end
  end
  
  describe "#haml_glob" do
    it "globs haml files" do
      Dir.glob(@builder.haml_glob).should_not be_empty
    end
    
    it "globs only haml files" do
      Dir.glob(@builder.haml_glob).reject{|file| file.match HamlRegex}.should be_empty
    end
  end
  
  describe "#sass_glob" do
    it "globs sass files" do
      Dir.glob(@builder.sass_glob).should_not be_empty
    end
    
    it "globs only sass files" do
      Dir.glob(@builder.sass_glob).reject{|file| file.match SassRegex}.should be_empty
    end
  end
  
  describe "jabs_glob" do
    it "globs jabs files" do
      Dir.glob(@builder.jabs_glob).should_not be_empty
    end
    
    it "globs only jabs files" do
      Dir.glob(@builder.jabs_glob).reject{|file| file.match JabsRegex}.should be_empty
    end
  end
  
  describe "spec_glob" do
    it "globs spec files" do
      Dir.glob(@builder.spec_glob).should_not be_empty
    end
    
    it "globs only spec files" do
      Dir.glob(@builder.spec_glob).reject{|file| file.match SpecRegex}.should be_empty
    end
  end
end
  
describe HamlRegex do
  it "matches haml file names" do
    HamlRegex.match("template.html.haml").should_not == nil
  end
end

describe SassRegex do
  it "matches sass file names" do
    SassRegex.match("stylesheet.css.sass").should_not == nil
  end
end

describe JabsRegex do
  it "matches jabs file names" do
    JabsRegex.match("demandlet.js.jabs").should_not == nil
  end
end

describe SpecRegex do
  it "matches spec file names" do
    SpecRegex.match("demandlet.html.jass").should_not == nil
  end
end

describe Builder::SrcRegex do
  it "matches 'src'" do
    Builder::SrcRegex.match("string-with-src-in-it").should_not == nil
  end
end

describe Builder::BuildDirectory do
  it "is 'build'" do
    Builder::BuildDirectory.should == 'build'
  end
end
