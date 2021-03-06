require 'rubygems'
require 'pathname'
require 'spec'
require 'launchy'

__DIR__ = path = Pathname.new(__FILE__).dirname.expand_path


task :default => "spec:all"

desc "Watch files for changes and rebuild on the fly."
task :build => :environment do
  require 'lib/lucky7/builder'
  Lucky7::Builder.build_continuously
end

task :environment do
  require 'config/environment'
end

namespace :spec do
  task :default => :all

  task :prepare => :environment do 
    @specs= Dir.glob("#{Lucky7Root}/rspec/**/*.rb").join(' ')
    p @specs
  end
  
  task :all => :prepare do
    system "spec #{@specs}"
  end
  
  task :doc => :prepare do
    system "spec #{@specs} --format specdoc"
  end

  task :build => :environment do
    require 'tools/spec_builder'
    Lucky7::SpecBuilder.new.build_continuously
  end  

  namespace :js do
    task :run => :environment do
      browser = Launchy::Browser.new
      Dir.glob("#{Lucky7Root}/jspec/**/*.html").each do |spec|
        browser.visit spec 
      end
    end

    task :example => :environment do
      class JsSpecExampleBuilder < Lucky7::Builder
        SrcRegex= Regexp.new "lib/jsspec"
        BuildDirectory= "vendor/js_spec"

        builds Jass,
          :files => "#{Lucky7Root}/lib/jsspec/example.html.jass"
      end

      JsSpecExampleBuilder.new.build_all

      Launchy::Browser.new.visit("file://#{Lucky7Root}/vendor/js_spec/example.html")
    end
  end
end

task :install => :environment do
  p "email collintmiller@gmail.com for help" unless system %{
    sudo python #{Lucky7Root}/vendor/orbited/ez_setup.py orbited;
    sudo easy_install demjson;
    sudo easy_install rel;
    sudo apt-get install python-dev libevent1 libevent-dev gcc libc6-dev;
    cd #{Lucky7Root}/vendor/orbited/pyevent-0.3/;
    sudo python setup.py install;
  }
end

task :cleanup do 
  Dir.glob("**/*.*~")+Dir.glob("**/*~").each{|swap|FileUtils.rm(swap, :force => true)}
end

namespace :gem do
  task :spec do
    file = File.new("#{__DIR__}/lucky7.gemspec", 'w+')
    file.write %{
Gem::Specification.new do |s|
  s.name             = "lucky7"
  s.version          = "0.0.1"
  s.platform         = Gem::Platform::RUBY
  s.has_rdoc         = false
  s.summary          = "A Ruby/Javascript web toolkit."
  s.description      = s.summary
  s.author           = "Collin Miller"
  s.email            = "collintmiller@gmail.com"
  s.homepage         = "http://github.com/collin/lucky7"
  s.require_path     = "lib"
  s.files            = %w{#{((README Rakefile.rb) + Dir.glob("{config,lib,rspec,templates,vendor}/**/*")).join(' ')}}
  
  s.add_dependency  "rake"
  s.add_dependency  "rspec"
  s.add_dependency  "basis"
  s.add_dependency  "haml"
  #s.add_dependency "jabs"
  s.add_dependency "jass"
end
}
  end
end

namespace :gen do
  task :app => :environment do
    app_name = ENV['Name']
    raise "What name for your app?" unless app_name
    generator = Lucky7::Generator.new(Lucky7Root + "apps")
    generator.skeleton(app_name)
  end
end
