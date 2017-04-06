# etcdv3-ruby  [![Gem Version](https://badge.fury.io/rb/etcdv3.svg)](https://badge.fury.io/rb/etcdv3) [![Build Status](https://travis-ci.org/davissp14/etcdv3-ruby.svg?branch=master)](https://travis-ci.org/davissp14/etcdv3-ruby)

Ruby client for Etcd V3

**Warning: This is under active development and should be considered unstable**

## Getting Started

[RubyDocs](http://www.rubydoc.info/gems/etcdv3/0.1.1/Etcd)

To install etcdv3, run the following command:
```
gem install etcdv3
```

**Establishing a connection**

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

**Adding, Fetching and Deleting Keys**
```
 # Put
 conn.put("my", "value")

 # Get
 conn.get("my")

 # Get Key Range
 conn.get('my', 'myyyy')

 # Delete Key
 conn.del('my')

 # Delete Key Range
 conn.del('my', 'myyy')
 ```

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
conn.add_role('rolename')

# Grant Permission to Role
conn.grant_permission_to_role('rolename', 'readwrite', 'a', 'z')

# Delete Role
conn.delete_role('rolename')

# List Roles
conn.role_list
```

**Authentication Management**
```
# Configure a root user
conn.add_user('root', 'mysecretpassword')

# Grant root user the root role
conn.grant_role_to_user('root', 'root')

# Enable Authentication
conn.enable_auth
```
After you enable authentication, you must authenticate.
```
# This will generate and assign an auth token that will be used in future requests.
conn.authenticate('root', 'mysecretpassword')
```
Disabling auth will clear the auth token and all previously attached user information
```
conn.disable_auth
```

**Leases**
```
# Grant a lease with a 100 second TTL
conn.grant_lease(100)

# Attach key to lease
conn.put("testkey", "testvalue", lease: 1234566789)

# Get information about lease and its attached keys
conn.lease_ttl(1234566789)

# Revoke lease and delete all keys attached
conn.revoke_lease(1234566789)
```

**Alarms**
```
# List all active Alarms
conn.alarm_list

# Deactivate ALL active Alarms
conn.deactivate_alarms
```
