require 'grpc'
require 'uri'

require 'etcdv3/etcdrpc/rpc_services_pb'
require 'etcdv3/etcdrpc/v3lock_services_pb'
require 'etcdv3/auth'
require 'etcdv3/kv/requests'
require 'etcdv3/kv/transaction'
require 'etcdv3/kv'

require 'etcdv3/namespace/utilities'
require 'etcdv3/namespace/kv/requests'
require 'etcdv3/namespace/kv/transaction'
require 'etcdv3/namespace/lock'
require 'etcdv3/namespace/kv'
require 'etcdv3/namespace/watch'

require 'etcdv3/maintenance'
require 'etcdv3/lease'
require 'etcdv3/watch'
require 'etcdv3/lock'
require 'etcdv3/connection'
require 'etcdv3/connection_wrapper'

class Etcdv3
  extend Forwardable
  def_delegators :@conn, :user, :password, :token, :endpoints, :authenticate

  attr_reader :conn, :credentials, :options
  DEFAULT_TIMEOUT = 120

  def initialize(**options)
    @options = options
    @timeout = options[:command_timeout] || DEFAULT_TIMEOUT
    @namespace = options[:namespace]
    @conn = ConnectionWrapper.new(
      @timeout,
      *sanitized_endpoints,
      @namespace,
      @options.fetch(:allow_reconnect, true),
      grpc_options: @options.fetch(:grpc_options, {}),
    )
    warn "WARNING: `url` is deprecated. Please use `endpoints` instead." if @options.key?(:url)
    authenticate(@options[:user], @options[:password]) if @options.key?(:user)
  end

  # Version of Etcd running on member
  def version
    @conn.handle(:maintenance, 'member_status').version
  end

  # Store size in bytes.
  def db_size
    @conn.handle(:maintenance, 'member_status').dbSize
  end

  # Cluster leader id
  def leader_id
    @conn.handle(:maintenance, 'member_status').leader
  end

  # List active alarms
  def alarm_list
    @conn.handle(:maintenance, 'alarms', [:get, leader_id])
  end

  # Disarm alarms on a specified member.
  def alarm_deactivate
    @conn.handle(:maintenance, 'alarms', [:deactivate, leader_id])
  end

  # Enables authentication.
  def auth_enable(timeout: nil)
    @conn.handle(:auth, 'auth_enable', [timeout: timeout])
    true
  end

  # Disables authentication.
  # This will clear any active auth / token data.
  def auth_disable(timeout: nil)
    @conn.handle(:auth, 'auth_disable', [timeout: timeout])
    @conn.clear_authentication
    true
  end

  # key                           - string
  # optional :range_end           - string
  # optional :limit               - integer
  # optional :revision            - integer
  # optional :sort_order          - symbol - [:none, :ascend, :descend]
  # optional :sort_target         - symbol - [:key, :version, :create, :mode, :value]
  # optional :serializable        - boolean
  # optional :keys_only           - boolean
  # optional :count_only          - boolean
  # optional :min_mod_revision    - integer
  # optional :max_mod_revision    - integer
  # optional :min_create_revision - integer
  # optional :max_create_revision - integer
  # optional :timeout             - integer
  def get(key, opts={})
    @conn.handle(:kv, 'get', [key, opts])
  end

  # Locks distributed lock with the given name. The lock will unlock automatically
  # when lease with the given ID expires. If this is not desirable, provide a non-expiring
  # lease ID as an argument.
  # name                          - string
  # lease_id                      - integer
  # optional :timeout             - integer
  def lock(name, lease_id, timeout: nil)
    @conn.handle(:lock, 'lock', [name, lease_id, {timeout: timeout}])
  end

  # Unlock distributed lock using the key previously obtained from lock.
  # key                           - string
  # optional :timeout             - integer
  def unlock(key, timeout: nil)
    @conn.handle(:lock, 'unlock', [key, {timeout: timeout}])
  end

  # Yield into the critical section while holding lock with the given
  # name. The lock will be unlocked even if the block throws.
  # name                          - string
  # lease_id                      - integer
  # optional :timeout             - integer
  def with_lock(name, lease_id, timeout: nil)
    key = lock(name, lease_id, timeout: timeout).key
    begin
      yield
    ensure
      unlock(key, timeout: timeout)
    end
  end

  # Inserts a new key.
  # key                           - string
  # value                         - string
  # optional :lease               - integer
  # optional :timeout             - integer
  def put(key, value, opts={})
    @conn.handle(:kv, 'put', [key, value, opts])
  end

  # Deletes a specified key
  # key                           - string
  # optional :range_end           - string
  # optional :timeout             - integer
  def del(key, opts={})
    @conn.handle(:kv, 'del', [key, opts])
  end

  # Grant a lease with a specified TTL
  def lease_grant(ttl, timeout: nil)
    @conn.handle(:lease, 'lease_grant', [ttl, timeout: timeout])
  end

  # Revokes lease and delete all attached keys
  def lease_revoke(id, timeout: nil)
    @conn.handle(:lease, 'lease_revoke', [id, timeout: timeout])
  end

  # Returns information regarding the current state of the lease
  def lease_ttl(id, timeout: nil)
    @conn.handle(:lease, 'lease_ttl', [id, timeout: timeout])
  end

  # Sends one lease keep-alive request
  def lease_keep_alive_once(id, timeout: nil)
    @conn.handle(:lease, 'lease_keep_alive_once', [id, timeout: timeout])
  end

  # List all roles.
  def role_list(timeout: nil)
    @conn.handle(:auth, 'role_list', [timeout: timeout])
  end

  # Add role with specified name.
  def role_add(name, timeout: nil)
    @conn.handle(:auth, 'role_add', [name, timeout: timeout])
  end

  # Fetches a specified role.
  def role_get(name, timeout: nil)
    @conn.handle(:auth, 'role_get', [name, timeout: timeout])
  end

  # Delete role.
  def role_delete(name, timeout: nil)
    @conn.handle(:auth, 'role_delete', [name, timeout: timeout])
  end

  # Grants a new permission to an existing role.
  def role_grant_permission(name, permission, key, range_end: '', timeout: nil)
    @conn.handle(:auth, 'role_grant_permission', [name, permission, key, range_end, timeout: timeout])
  end

  def role_revoke_permission(name, permission, key, range_end: '', timeout: nil)
    @conn.handle(:auth, 'role_revoke_permission', [name, permission, key, range_end, timeout: timeout])
  end

  # Fetch specified user
  def user_get(user, timeout: nil)
    @conn.handle(:auth, 'user_get', [user, timeout: timeout])
  end

  # Creates new user.
  def user_add(user, password, timeout: nil)
    @conn.handle(:auth, 'user_add', [user, password, timeout: timeout])
  end

  # Delete specified user.
  def user_delete(user, timeout: nil)
    @conn.handle(:auth, 'user_delete', [user, timeout: timeout])
  end

  # Changes the specified users password.
  def user_change_password(user, new_password, timeout: nil)
    @conn.handle(:auth, 'user_change_password', [user, new_password, timeout: timeout])
  end

  # List all users.
  def user_list(timeout: nil)
    @conn.handle(:auth, 'user_list', [timeout: timeout])
  end

  # Grants role to an existing user.
  def user_grant_role(user, role, timeout: nil)
    @conn.handle(:auth, 'user_grant_role', [user, role, timeout: timeout])
  end

  # Revokes role from a specified user.
  def user_revoke_role(user, role, timeout: nil)
    @conn.handle(:auth, 'user_revoke_role', [user, role, timeout: timeout])
  end

  # Watches for changes on a specified key range.
  def watch(key, range_end: nil, start_revision: nil, timeout: nil, &block)
    @conn.handle(:watch, 'watch', [key, range_end, start_revision, block, timeout: timeout])
  end

  def transaction(timeout: nil, &block)
    @conn.handle(:kv, 'transaction', [block, timeout: timeout])
  end

  private

  def sanitized_endpoints
    (@options[:endpoints] || @options[:url]).split(',').map(&:strip)
  end
end
