$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "nyan-cat-chef-formatter"
  s.version     = "0.1.0"
  s.authors     = ["Andrea Campi"]
  s.email       = ["andrea.campi@zephirworks.com"]
  s.homepage    = "https://github.com/andreacampi/nyan-cat-chef-formatter"
  s.summary     = %q{Nyan Cat inspired Chef formatter}
  s.description = %q{Nyan Cat inspired Chef formatter}

  s.rubyforge_project = "nyan-cat-chef-formatter"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
