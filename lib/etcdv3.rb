require 'grpc'
require 'uri'

require 'etcdv3/etcdrpc/rpc_services_pb'
require 'etcdv3/auth'
require 'etcdv3/kv/requests'
require 'etcdv3/kv/transaction'
require 'etcdv3/kv'
require 'etcdv3/maintenance'
require 'etcdv3/lease'
require 'etcdv3/watch'
require 'etcdv3/cluster'
require 'etcdv3/connection'
require 'etcdv3/connection_wrapper'

class Etcdv3
  extend Forwardable
  def_delegators :@conn, :user, :password, :token, :endpoints, :authenticate

  attr_reader :conn, :options

  def initialize(options = {})
    @options = options
    @conn = ConnectionWrapper.new(sanitized_endpoints)
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

  # List members in cluster
  def member_list
    @conn.handle(:cluster, 'member_list')
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
  def auth_enable
    @conn.handle(:auth, 'auth_enable')
    true
  end

  # Disables authentication.
  # This will clear any active auth / token data.
  def auth_disable
    @conn.handle(:auth, 'auth_disable')
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
  def get(key, opts={})
    @conn.handle(:kv, 'get', [key, opts])
  end

  # Inserts a new key.
  def put(key, value, lease_id: nil)
    @conn.handle(:kv, 'put', [key, value, lease_id])
  end

  # Deletes a specified key
  def del(key, range_end: '')
    @conn.handle(:kv, 'del', [key, range_end])
  end

  # Grant a lease with a specified TTL
  def lease_grant(ttl)
    @conn.handle(:lease, 'lease_grant', [ttl])
  end

  # Revokes lease and delete all attached keys
  def lease_revoke(id)
    @conn.handle(:lease, 'lease_revoke', [id])
  end

  # Returns information regarding the current state of the lease
  def lease_ttl(id)
    @conn.handle(:lease, 'lease_ttl', [id])
  end

  # List all roles.
  def role_list
    @conn.handle(:auth, 'role_list')
  end

  # Add role with specified name.
  def role_add(name)
    @conn.handle(:auth, 'role_add', [name])
  end

  # Fetches a specified role.
  def role_get(name)
    @conn.handle(:auth, 'role_get', [name])
  end

  # Delete role.
  def role_delete(name)
    @conn.handle(:auth, 'role_delete', [name])
  end

  # Grants a new permission to an existing role.
  def role_grant_permission(name, permission, key, range_end='')
    @conn.handle(:auth, 'role_grant_permission', [name, permission, key, range_end])
  end

  def role_revoke_permission(name, permission, key, range_end='')
    @conn.handle(:auth, 'role_revoke_permission', [name, permission, key, range_end])
  end

  # Fetch specified user
  def user_get(user)
    @conn.handle(:auth, 'user_get', [user])
  end

  # Creates new user.
  def user_add(user, password)
    @conn.handle(:auth, 'user_add', [user, password])
  end

  # Delete specified user.
  def user_delete(user)
    @conn.handle(:auth, 'user_delete', [user])
  end

  # Changes the specified users password.
  def user_change_password(user, new_password)
    @conn.handle(:auth, 'user_change_password', [user, new_password])
  end

  # List all users.
  def user_list
    @conn.handle(:auth, 'user_list')
  end

  # Grants role to an existing user.
  def user_grant_role(user, role)
    @conn.handle(:auth, 'user_grant_role', [user, role])
  end

  # Revokes role from a specified user.
  def user_revoke_role(user, role)
    @conn.handle(:auth, 'user_revoke_role', [user, role])
  end

  # Watches for changes on a specified key range.
  def watch(key, range_end: '', &block)
    @conn.handle(:watch, 'watch', [key, range_end, block])
  end

  def transaction(&block)
    @conn.handle(:kv, 'transaction', [block])
  end

  private

  def sanitized_endpoints
    (@options[:endpoints] || @options[:url]).split(',').map(&:strip)
  end
end
