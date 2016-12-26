require_relative './lib/version.rb'
Gem::Specification.new do |s|
  s.name        = "sinatra_sockets"
  s.version     = SinatraSockets::VERSION
  s.date        = "2016-12-25"
  s.summary     = "a generator for a sinatra websockets app"
  s.description = ""
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["maxpleaner"]
  s.email       = 'maxpleaner@gmail.com'
  s.required_ruby_version = '~> 2.3'
  s.homepage    = "http://github.com/maxpleaner/sinatra_sockets"
  s.files       = Dir["lib/**/*", "bin/*", "**/*.md", "LICENSE"]
  s.require_path = 'lib'
  s.required_rubygems_version = ">= 2.5.1"
  s.executables = Dir["bin/*"].map &File.method(:basename)
  s.add_dependency 'gemmyrb'
  s.license     = 'MIT'
end
