# Description

Proof of concept Etcd V3 Client.

# Install

     # Pull down Repository
     git clone https://github.ibm.com/shaund/etcd3-ruby.git

     # Build the Gem
     cd etcd3-ruby && gem build etcdv3.gemspec

     # Install Gem
     gem install etcdv3

# Usage

     require 'etcd' # This wasn't a typo.

     # Initialize Client
     conn = Etcd.new("http://127.0.0.1:2379")

     # Initialize secure connection using default certificates
     conn = Etcd.new('https://hostname:port')

     # Initialize secure connection with auth
     conn = Etcd.new('https://hostname:port', user: "gary", password: "secret")

     # Put
     conn.put("my", "value")

     # Range
     conn.range("my")
