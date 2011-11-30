require File.expand_path('../lib/gitvault/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "gitvault"
  s.version     = Gitvault::VERSION.dup
  s.summary     = "Your personal git hosting"
  s.description = "TO BE FILLED"
  s.homepage    = "http://github.com/sosedoff/gitvault"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'thin'
  s.add_development_dependency 'shotgun'
  
  s.add_runtime_dependency 'sinatra', '~> 1.3'
  s.add_runtime_dependency 'vegas',   '~> 0.1.8'
  s.add_runtime_dependency 'json'
  
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths      = ["lib"]
  s.default_executable = 'gitvault'
end