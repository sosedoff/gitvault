task :build do
  require 'fileutils'
  require File.expand_path('../lib/gitvault/version', __FILE__)
  
  gem_file = "gitvault-#{Gitvault::VERSION}.gem"
  
  if File.exists?(gem_file)
    FileUtils.rm_f(gem_file)
  end
  
  puts "-> Uninstalling..."
  puts `gem uninstall -x gitvault --version=#{Gitvault::VERSION}`
  
  puts "-> Building..."
  puts `gem build gitvault.gemspec`
  
  puts "-> Installing..."
  puts `gem install --no-ri --no-rdoc gitvault-#{Gitvault::VERSION}.gem`
end
