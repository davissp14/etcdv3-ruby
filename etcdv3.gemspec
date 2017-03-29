$:.unshift File.expand_path("../lib", __FILE__)

require "etcd/version"

Gem::Specification.new do |s|
  s.name = "etcdv3"
  s.version = Etcd::VERSION
  s.homepage = "https://github.ibm.com/shaund/etcd3-ruby"
  s.summary = "A Etcd client library for Version 3"
  s.description = "Coming soon"
  s.license = "MIT"
  s.authors = ["Shaun Davis"]
  s.email = "shaund@us.ibm.com"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency("grpc", "1.2.0")
  s.add_development_dependency("rspec", "3.5.4")
end
