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
  s.files            = %w(README Rakefile.rb) + Dir.glob("{config,lib,rspec,templates,vendor}/**/*")
  
  s.add_dependency  "rake"
  s.add_dependency  "rspec"
  s.add_dependency  "basis"
  s.add_dependency  "haml"
  #s.add_dependency "jabs"
  #s.add_dependency "jass"
end