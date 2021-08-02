# etcdv3-ruby  [![Gem Version](https://badge.fury.io/rb/etcdv3.svg)](https://badge.fury.io/rb/etcdv3) [![Build Status](https://travis-ci.org/davissp14/etcdv3-ruby.svg?branch=master)](https://travis-ci.org/davissp14/etcdv3-ruby) [![codecov](https://codecov.io/gh/davissp14/etcdv3-ruby/branch/master/graph/badge.svg)](https://codecov.io/gh/davissp14/etcdv3-ruby)


Ruby client for Etcd V3

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
conn = Etcdv3.new(endpoints: 'http://127.0.0.1:2379, http://127.0.0.1:2389, http://127.0.0.1:2399')

# Secure connection using default certificates
conn = Etcdv3.new(endpoints: 'https://hostname:port')

# Secure connection with Auth
conn = Etcdv3.new(endpoints: 'https://hostname:port', user: 'root', password: 'mysecretpassword')

# Scope CRUD operations to a specific keyspace. 
conn = Etcdv3.new(endpoints: 'https://hostname:port', namespace: "/target_keyspace/")

# Secure connection specifying custom certificates
# Coming soon...

```
**High Availability**

In the event of a failure, the client will work to restore connectivity by cycling through the specified endpoints until a connection can be established.  With that being said, it is encouraged to specify multiple endpoints when available.

However, sometimes this is not what you want. If you need more control over
failures, you can suppress this mechanism by using

```ruby
conn = Etcdv3.new(endpoints: 'https://hostname:port', allow_reconnect: false)
```

This will still rotate the endpoints, but it will raise an exception so you can
handle the failure yourself. On next call to the new endpoint (since they were
rotated) is tried. One thing you need to keep in mind if auth is enabled, you 
need to take care of `GRPC::Unauthenticated` exception and manually re-authenticate 
when token expires. To reiterate, you are responsible for handling the errors, so 
some understanding of how this gem and etcd works is recommended.

## Namespace support

Namespacing is a convenience feature used to scope CRUD based operations to a specific keyspace.

```ruby
# Establish connection
conn = Etcdv3.new(endpoints: 'https://hostname:port', namespace: '/service-a/')

# Write key to /service-a/test_key
conn.put("test_key", "value"). 

# Get the key we just wrote.
conn.get("test_key")

# Retrieve everything under the namespace.
conn.get("", "\0") 

# Delete everything under the namespace.
conn.del("", "\0")
```

_Note: Namespaces are stripped from responses._


## Adding, Fetching and Deleting Keys
```ruby
 # Put
 conn.put('foo', 'bar')

 # Get
 conn.get('my')

 # Get actual value
 value = conn.get('my').kvs.first.value

 # Get Key Range
 conn.get('foo', range_end: 'foo80')

 # Delete Key
 conn.del('foo')

 # Delete Key Range
 conn.del('foo', range_end: 'foo80')
 ```

## User Management
```ruby
# Add User
conn.user_add('admin', 'secret')

# Delete User
conn.user_delete('admin')

# Get User
conn.user_get('admin')

# List Users
conn.user_list
```

## Role Management
```ruby
# Add Role
conn.role_add('admin')

# Grant Permission to Role
conn.role_grant_permission('admin', :readwrite, 'foo', 'foo99')

# Delete Role
conn.role_delete('admin')

# List Roles
conn.role_list
```

## Authentication Management
```ruby
# Configure a root user
conn.user_add('root', 'mysecretpassword')

# Grant root role to root user
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
conn.put('foo', 'bar', lease: 1234566789)

# Get information about lease and its attached keys
conn.lease_ttl(1234566789)

# Revoke lease and delete all keys attached
conn.lease_revoke(1234566789)
```

## Transaction
Transactions provide an easy way to process multiple requests in a single transaction.

_Note: You cannot modify the same key multiple times within a single transaction._

```ruby
# https://github.com/davissp14/etcdv3-ruby/blob/master/lib/etcdv3/kv/transaction.rb
conn.transaction do |txn|
  txn.compare = [
    # Is the value of 'target_key' equal to 'compare_value'
    txn.value('target_key', :equal, 'compare_value'),
    # Is the version of 'target_key' greater than 10
    txn.version('target_key', :greater, 10)
  ]

  txn.success = [
    txn.put('txn1', 'success')
  ]

  txn.failure = [
    txn.put('txn1', 'failed', lease: lease_id)
  ]
end
```

## Watch
```ruby
# Watch for changes on a specified key for at most 10 seconds and return
events = conn.watch('foo', timeout: 10)

# Watch for changes on a specified key range and return
events = conn.watch('foo', range_end: 'fop')

# Watch for changes since a given revision
events = conn.watch('foo', start_revision: 42)

# Watches for changes continuously until killed.
event_count = 0
conn.watch('boom') do |events|
  puts events
  event_count = event_count + 1
  break if event_count >= 10
end
```

## Locks
```ruby
# First, get yourself a lease
lease_id = conn.lease_grant(100)['ID']

# Attempt to lock distibuted lock 'foo', wait at most 10 seconds
lock_key = conn.lock('foo', lease_id, timeout: 10).key

# Unlock the 'foo' lock using the key returned from `lock`
conn.unlock(key)

# Perform a critical section while holding the lock 'hello'
conn.with_lock('hello', lease_id) do
  puts "kitty!"
end
```

## Alarms
```ruby
# List all active Alarms
conn.alarm_list

# Deactivate ALL active Alarms
conn.alarm_deactivate
```

## Timeouts

The default timeout for all requests is 120 seconds.

```ruby
# Specify `command_timeout` to override the default global timeout.
conn = Etcdv3.new(endpoints: 'https://hostname:port', command_timeout: 5) # 5 seconds

# You can also specify request specific timeouts.
conn.get("foo", timeout: 2)
```

Timeouts apply to and can be set when:
 - Adding, Fetching and Deleting keys
 - User, Role, and Authentication Management
 - Leases
 - Transactions

_Note: Timeouts currently do not affect Watch or Maintenance related commands._

## Contributing

If you're looking to get involved, [Fork the project](https://github.com/davissp14/etcdv3-ruby) and send pull requests.
