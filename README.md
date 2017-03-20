# etcdv3-ruby

# Example

     # Require file. (This will make more sense when it's a gem.
    `require "/path/to/lib/etcd"`
    
     # Initialize Client
     client = Etcd::Client.new
     
     # Authentication
     client.authenticate("user", "password")
     
     # Put
     client.put("my", "value")
     
     # Range
     client.range("my")

