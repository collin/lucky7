require 'rubygems'
require 'spec'

desc "Watch files for changes and rebuild on the fly."
task :build => :environment do
  require 'lib/lucky7/builder'
  Lucky7::Builder.build_continuously
end

task :environment do
  require 'config/environment'
end

namespace :spec do
  task :prepare => :environment do 
    @specs= Dir.glob("#{Lucky7Root}/rspec/**/*.rb").join(' ')
  end
  
  task :all => :prepare do
    system "spec #{@specs}"
  end
  
  task :doc => :prepare do
    system "spec #{@specs} --format specdoc"
  end
  
  namespace :js do
    task :example => :environment do
      Lucky7::Builder.build_spec ["#{Lucky7Root}/lib/jsspec/example.html.jass"]
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

task :take_home do
  "insert your thumb drive, dumbass!" unless system %{
    sudo cp -R ~/workspace/lucky7 /media/disk
  }
end

task :bring_back do
  "insert your thumb drive, dumbass!" unless system %{
    sudo cp -R /media/disk/lucky7 ~/workspace/ 
  }  
end
