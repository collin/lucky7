require 'rspec/lucky7_spec_helper'

include Lucky7
include Builder
    
Builder.const_set :Lucky7Root, FixtureRoot

HamlRegex= /html\.haml/
SassRegex= /css\.sass/
JabsRegex= /\.js/
SpecRegex= /html\.jass/
FixtureRegex= /fixtures/

describe Builder do
  it "inherits Module" do
    Builder.class.should == Module
  end
end

describe Builder::Lucky7Root do
  it "is a fixture" do
    Builder::Lucky7Root.match(FixtureRegex).should_not == nil
  end
end

describe Builder, ".build" do
  before(:each) do
    Builder.cache_mtimes!
  end

  it "builds spec files" do
    Builder.should_receive(:build_spec).once
    Builder.build
  end

  it "builds haml files" do
    Builder.should_receive(:build_haml).once
    Builder.build
  end
  
  it "builds sass files" do
    Builder.should_receive(:build_sass).once
    Builder.build
  end
  
  it "builds jabs files" do
    Builder.should_receive(:build_jabs).once
    Builder.build
  end
  
  it "packs" do
    Builder.should_receive(:pack).once
    Builder.build
  end
end

describe Builder, ".build_path_for" do  
  it "constructs a build path" do
    Builder.build_path_for(:extension, "#{Lucky7Root}/src/some_file.extension_.processor").should == "#{Lucky7Root}/build/some_file.extension"
  end
  
  it "maintains path depth" do
    Builder.build_path_for(:extension, "#{Lucky7Root}/src/place/some_file.extension_.processor").should == "#{Lucky7Root}/build/place/some_file.extension"
  end
  
  it "builds multi dot files" do
    Builder.build_path_for("spec.html", "#{Lucky7Root}/src/place/some_file.extension.processor").should == "#{Lucky7Root}/build/place/some_file.spec.html"
  end
end

describe Builder, ".files" do
  it "contains haml files" do
    Builder.files[:haml].should_not be_empty
  end
  
  it "contains jabs files" do
    Builder.files[:jabs].should_not be_empty
  end
  
  it "contains sass files" do
    Builder.files[:sass].should_not be_empty
  end
  
  it "contains spec files" do
    Builder.files[:spec].should_not be_empty
  end
end

describe Builder, ".files_flattened" do
  it "returns an array" do
    Builder.files_flattened.class.should == Array
  end
  
  it "is flat" do
    files = Builder.files_flattened
    files.should == files.flatten
  end
end

describe Builder, ".mtimes" do
  it "returns a hash" do
    Builder.mtimes.class.should == Hash
  end

  it "keys are filenames" do
    Builder.mtimes.reject{|key, value| File.exists? key}.should be_empty
  end

  it "values are Times" do
    Builder.mtimes.reject{|key, value| value.is_a? Time}.should be_empty
  end
end

describe Builder, ".build_haml" do
  before(:each) do
    @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.html.haml"
    @build_glob= "#{Builder::Lucky7Root}/build/app/*.html"
    build= Dir.glob @build_glob
    FileUtils.rm build, :force => true
  end
  
  it "renders html documents" do
    Builder.build_haml(@src)
    Dir.glob(@build_glob).length.should == @src.length  
  end
end

describe Builder, ".build_sass" do
  before(:each) do
    @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.css.sass"
    @build_glob= "#{Builder::Lucky7Root}/build/app/*.css"
    build= Dir.glob @build_glob
    FileUtils.rm build, :force => true
  end
  
  it "renders css files" do
    Builder.build_sass(@src)
    Dir.glob(@build_glob).length.should == @src.length  
  end
end

describe Builder, ".build_spec" do
  before(:each) do
    @src= Dir.glob "#{Builder::Lucky7Root}/src/app/*.spec.yaml"
    @build_glob= "#{Builder::Lucky7Root}/build/app/*.spec.html"
    build= Dir.glob @build_glob
    FileUtils.rm build, :force => true
  end
  
  it "renders jsspec files" do
    Builder.build_spec(@src)
    Dir.glob(@build_glob).length.should == @src.length  
  end
end

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

describe Builder, ".haml_render_context" do
  it "is Lucky7::Renders" do
    Builder.haml_render_context.should == Lucky7::Renders
  end
end

describe Builder, ".modified_files" do
  before(:each) do
    Builder.cache_mtimes!
  end

  it "returns a Hash" do
    Builder.modified_files.class.should == Hash
  end

  it "contains modified files names" do
    modify_file!
    Builder.modified_files[:haml].should_not be_empty
  end

  it "ignores unmodified files" do
    Builder.modified_files[:haml].should be_empty
  end

  it "contains new files" do
    file = "#{Builder::Lucky7Root}/src/app/touche.js.jabs"
    FileUtils.touch(file)
    Builder.modified_files[:jabs].should include(file)
    FileUtils.rm(file)
  end
end

describe Builder, ".cache_mtimes!" do
  it "caches_mtimes" do
    Builder.cache_mtimes!
    Builder.instance_variable_get(:@cached_mtimes).should == Builder.mtimes
  end
end

describe Builder, ".cached_mtimes" do
  before(:each) do
    Builder.cache_mtimes!
  end

  it "returns a hash" do 
    Builder.cached_mtimes.class.should == Hash
  end

  it "same as mtimes if no change" do
    Builder.cached_mtimes.should == Builder.mtimes
  end

  it "holds old mtimes" do
    modify_file!
    Builder.cached_mtimes.should_not == Builder.mtimes
  end
end

describe Builder, ".ensure_build_path!" do
  it "makes all parent dirs" do
    Builder.ensure_build_path! "#{Builder::Lucky7Root}/build/app/layout.html.haml"
    File.exists?("#{Builder::Lucky7Root}/build/app/").should == true
    FileUtils.rm_rf "#{Builder::Lucky7Root}/build/app"
  end
end

describe Builder, ".build_continuously" do
  it "caches mtimes" do
    Builder.should_receive(:cache_mtimes!).once
    Builder.build_continuously false
  end

  it "builds" do 
    Builder.should_receive(:build).once
    Builder.build_continuously false
  end
end

describe Builder, ".haml_glob" do
  it "globs haml files" do
    Dir.glob(Builder.haml_glob).should_not be_empty
  end
  
  it "globs only haml files" do
    Dir.glob(Builder.haml_glob).reject{|file| file.match HamlRegex}.should be_empty
  end
end

describe Builder, ".sass_glob" do
  it "globs sass files" do
    Dir.glob(Builder.sass_glob).should_not be_empty
  end
  
  it "globs only sass files" do
    Dir.glob(Builder.sass_glob).reject{|file| file.match SassRegex}.should be_empty
  end
end

describe Builder, "jabs_glob" do
  it "globs jabs files" do
    Dir.glob(Builder.jabs_glob).should_not be_empty
  end
  
  it "globs only jabs files" do
    Dir.glob(Builder.jabs_glob).reject{|file| file.match JabsRegex}.should be_empty
  end
end

describe Builder, "spec_glob" do
  it "globs spec files" do
    Dir.glob(Builder.spec_glob).should_not be_empty
  end
  
  it "globs only spec files" do
    Dir.glob(Builder.spec_glob).reject{|file| file.match SpecRegex}.should be_empty
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

describe SrcRegex do
  it "matches 'src'" do
    SrcRegex.match("string-with-src-in-it").should_not == nil
  end
end

describe BuildDirectory do
  it "is 'build'" do
    BuildDirectory.should == 'build'
  end
end
