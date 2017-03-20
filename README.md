# Description

Proof of concept Etcd V3 Client.


# Example

     # Require file. (This will make more sense when it's a gem.
     require "/path/to/etcdv3-ruby/lib/etcd"`
    
     # Initialize Client
     client = Etcd::Client.new("127.0.0.1:2379")
     
     # Authentication
     client.authenticate("user", "password")
     
     # Put
     client.put("my", "value")
     
     # Range
     client.range("my")

