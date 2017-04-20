$:.unshift File.expand_path("../lib", __FILE__)

require "etcdv3/version"

Gem::Specification.new do |s|
  s.name = "etcdv3"
  s.version = Etcdv3::VERSION
  s.homepage = "https://github.com/davissp14/etcdv3-ruby"
  s.summary = "A Etcd client library for Version 3"
  s.description = "Etcd v3 Ruby Client"
  s.license = "MIT"
  s.authors = ["Shaun Davis"]
  s.email = "davissp14@gmail.com"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency("grpc", "1.2.5")
  s.add_dependency("faraday", "0.11.0")
  s.add_development_dependency("rspec")
end
