# etcdv3-ruby

Ruby client for Etcd V3

**WARNING: This is very much a work in progress and should be considered unstable.**

## Usage

     # Initialize insecure Client
     conn = Etcd.new(url: 'http://127.0.0.1:2379')

     # Initialize secure connection using default certificates
     conn = Etcd.new(url: 'https://hostname:port')

     # Initialize secure connection with auth
     conn = Etcd.new(url: 'https://hostname:port', user: "gary", password: "secret")

**Adding and Fetching Keys**
    
     # Put
     conn.put("my", "value")

     # Range
     conn.range("my")
          
**User Managment**
   
     # Add User
     conn.add_user('admin', 'secret')
     
     # Delete User
     conn.delete_user('admin')
     
     # List users
     conn.user_list
     
