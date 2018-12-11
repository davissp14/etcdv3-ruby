# frozen_string_literal: true

ETCD_VERSION = ENV["ETCD_VERSION"] || "v3.2.0"
ETCD_URL = "https://github.com/coreos/etcd/releases/download/#{ETCD_VERSION}/etcd-#{ETCD_VERSION}-linux-amd64.tar.gz"

require "tmpdir"

desc "Download etcd for it can be used in rspec"
task :"download-etcd" do
  tmpdir = Dir.mktmpdir
  system("wget", ETCD_URL, "-O", "#{tmpdir}/etcd.tar.gz")   || exit(1)
  system(*%W{tar -C #{tmpdir} -zxvf #{tmpdir}/etcd.tar.gz}) || exit(1)

  puts "Etcd downloaded and extracted. Add it to the path:"
  puts "    export PATH=\"#{tmpdir}/etcd-#{ETCD_VERSION}-linux-amd64:$PATH\""
end
