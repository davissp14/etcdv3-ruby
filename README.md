# etcdv3-ruby  [![Gem Version](https://badge.fury.io/rb/etcdv3.svg)](https://badge.fury.io/rb/etcdv3) [![Build Status](https://travis-ci.org/davissp14/etcdv3-ruby.svg?branch=master)](https://travis-ci.org/davissp14/etcdv3-ruby) [![codecov](https://codecov.io/gh/davissp14/etcdv3-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/davissp14/etcdv3-ruby)


Ruby client for Etcd V3

**Warning: This is under active development and should be considered unstable**

## Getting Started

[RubyDocs](http://www.rubydoc.info/gems/etcdv3)

To install etcdv3, run the following command:
```ruby
gem install etcdv3
```

## Establishing a connection

```ruby
require 'etcdv3'

# Insecure connection
conn = Etcdv3.new(url: 'http://127.0.0.1:2379')

# Secure connection using default certificates
conn = Etcdv3.new(url: 'https://hostname:port')

# Secure connection with Auth
conn = Etcdv3.new(url: 'https://hostname:port', user: "gary", password: "secret")

# Secure connection specifying own certificates
# Coming soon...
```

## Adding, Fetching and Deleting Keys
```ruby
 # Put
 conn.put("my", "value")

 # Get
 conn.get("my")

 # Get Key Range
 conn.get('my', range_end: 'myyyy')

 # Delete Key
 conn.del('my')

 # Delete Key Range
 conn.del('my', range_end: 'myyy')
 ```

## User Management
```ruby
 # Add User
 conn.user_add('admin', 'secret')

# Delete User
conn.user_delete('admin')

# List users
conn.user_list
```

## Role Management
```ruby
# Add Role
conn.role_add('rolename')

# Grant Permission to Role
conn.role_grant_permission('rolename', :readwrite, 'a', 'z')

# Delete Role
conn.role_delete('rolename')

# List Roles
conn.role_list
```

## Authentication Management
```ruby
# Configure a root user
conn.user_add('root', 'mysecretpassword')

# Grant root user the root role
conn.user_grant_role('root', 'root')

# Enable Authentication
conn.auth_enable
```
After you enable authentication, you must authenticate.
```ruby
# This will generate and assign an auth token that will be used in future requests.
conn.authenticate('root', 'mysecretpassword')
```
Disabling auth will clear the auth token and all previously attached user information
```
conn.auth_disable
```

## Leases
```ruby
# Grant a lease with a 100 second TTL
conn.lease_grant(100)

# Attach key to lease
conn.put("testkey", "testvalue", lease_id: 1234566789)

# Get information about lease and its attached keys
conn.lease_ttl(1234566789)

# Revoke lease and delete all keys attached
conn.lease_revoke(1234566789)
```

## Watch
```ruby
# Watch for changes on a specified key and return
events = conn.watch('names')

# Watch for changes on a specified key range and return
events = conn.watch('boom', range_end: 'booooooom')

# Watches for changes continuously until killed.
event_count = 0
conn.watch('boom') do |events|
  puts events
  event_count = event_count + 1
  break if event_count >= 10
end
```

## Alarms
```ruby
# List all active Alarms
conn.alarm_list

# Deactivate ALL active Alarms
conn.alarm_deactivate
```
