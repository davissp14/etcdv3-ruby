# etcdv3-ruby  [![Build Status](https://travis-ci.org/davissp14/etcdv3-ruby.svg?branch=master)](https://travis-ci.org/davissp14/etcdv3-ruby)

Ruby client for Etcd V3

**Note: This is under active development and is not feature complete**

## Getting Started

To install etcdv3, run the following command:
```
gem install etcdv3
```

You can connect to Etcd by instantiating the Etcd class:

```
require 'etcdv3'

# Insecure connection
conn = Etcd.new(url: 'http://127.0.0.1:2379')

# Secure connection using default certificates
conn = Etcd.new(url: 'https://hostname:port')

# Secure connection with Auth
conn = Etcd.new(url: 'https://hostname:port', user: "gary", password: "secret")

# Secure connection specifying own certificates
# Coming soon...
```

**Adding and Fetching Keys**

     # Put
     conn.put("my", "value")

     # Get
     conn.get("my")

     # Get Key Range
     conn.get('my', 'myyyy')

**User Management**
```
 # Add User
 conn.add_user('admin', 'secret')

# Delete User
conn.delete_user('admin')

# List users
conn.user_list
```

**Role Management**
```
# Add Role
conn.add_role('rolename', 'readwrite', 'a', 'Z')

# Delete Role
conn.delete_role('rolename')

# List Roles
conn.role_list

# Grant role to user
conn.grant_role_to_user('root', 'root')
```
