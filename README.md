# etcdv3-ruby

Ruby client for Etcd V3 - Very much a work in progress.

**WARNING: This is very much a work in progress and should be considered unstable.**

## Getting Started

     gem install etcdv3

## Usage

     require 'etcd' # This wasn't a typo.

     # Initialize insecure Client
     conn = Etcd.new(url: 'http://127.0.0.1:2379')

     # Initialize secure connection using default certificates
     conn = Etcd.new(url: 'https://hostname:port')

     # Initialize secure connection with auth
     conn = Etcd.new(url: 'https://hostname:port', user: "gary", password: "secret")

     # Put
     conn.put("my", "value")

     # Range
     conn.range("my")
