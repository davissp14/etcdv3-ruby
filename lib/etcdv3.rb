
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

require 'etcdv3/request'

class Etcdv3

  attr_reader :credentials, :options

  def uri
    URI(@options[:url])
  end

  def scheme
    uri.scheme
  end

  def port
    uri.port
  end

  def hostname
    uri.hostname
  end

  def user
    request.user
  end

  def password
    request.password
  end

  def token
    request.token
  end

  def key
    File.read(File.expand_path(@options[:key])) if options.has_key?(:key)
  end

  def cert
    File.read(File.expand_path(@options[:cert])) if options.has_key?(:cert)
  end

  def cacert
    File.read(File.expand_path(@options[:cacert])) if options.has_key?(:cacert)
  end

  def tls_creds
    # The order of the elements in the array is important
    [cacert, key, cert].compact
  end

  def initialize(options = {})
    @options = options
    @credentials = resolve_credentials
    authenticate(options[:user], options[:password]) unless options[:user].nil?
  end

  # Version of Etcd running on member
  def version
    request.handle(:maintenance, 'member_status').version
  end

  # Store size in bytes.
  def db_size
    request.handle(:maintenance, 'member_status').dbSize
  end

  # Cluster leader id
  def leader_id
    request.handle(:maintenance, 'member_status').leader
  end

  # List active alarms
  def alarm_list
    request.handle(:maintenance, 'alarms', [:get, leader_id])
  end

  # Disarm alarms on a specified member.
  def alarm_deactivate
    request.handle(:maintenance, 'alarms', [:deactivate, leader_id])
  end

  # Authenticate using specified user and password.
  # On successful authentication, an auth token will be assigned to the request instance.
  def authenticate(user, password)
    request.authenticate(user, password)
  end

  # Enables authentication.
  def auth_enable
    request.handle(:auth, 'auth_enable')
    true
  end

  # Disables authentication.
  # This will clear any active auth / token data.
  def auth_disable
    request.handle(:auth, 'auth_disable')
    request(reset: true)
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
    request.handle(:kv, 'get', [key, opts])
  end

  # Inserts a new key.
  def put(key, value, lease_id: nil)
    request.handle(:kv, 'put', [key, value, lease_id])
  end

  # Deletes a specified key
  def del(key, range_end: '')
    request.handle(:kv, 'del', [key, range_end])
  end

  # Grant a lease with a specified TTL
  def lease_grant(ttl)
    request.handle(:lease, 'lease_grant', [ttl])
  end

  # Revokes lease and delete all attached keys
  def lease_revoke(id)
    request.handle(:lease, 'lease_revoke', [id])
  end

  # Returns information regarding the current state of the lease
  def lease_ttl(id)
    request.handle(:lease, 'lease_ttl', [id])
  end

  # List all roles.
  def role_list
    request.handle(:auth, 'role_list')
  end

  # Add role with specified name.
  def role_add(name)
    request.handle(:auth, 'role_add', [name])
  end

  # Fetches a specified role.
  def role_get(name)
    request.handle(:auth, 'role_get', [name])
  end

  # Delete role.
  def role_delete(name)
    request.handle(:auth, 'role_delete', [name])
  end

  # Grants a new permission to an existing role.
  def role_grant_permission(name, permission, key, range_end='')
    request.handle(:auth, 'role_grant_permission', [name, permission, key, range_end])
  end

  def role_revoke_permission(name, permission, key, range_end='')
    request.handle(:auth, 'role_revoke_permission', [name, permission, key, range_end])
  end

  # Fetch specified user
  def user_get(user)
    request.handle(:auth, 'user_get', [user])
  end

  # Creates new user.
  def user_add(user, password)
    request.handle(:auth, 'user_add', [user, password])
  end

  # Delete specified user.
  def user_delete(user)
    request.handle(:auth, 'user_delete', [user])
  end

  # Changes the specified users password.
  def user_change_password(user, new_password)
    request.handle(:auth, 'user_change_password', [user, new_password])
  end

  # List all users.
  def user_list
    request.handle(:auth, 'user_list')
  end

  # Grants role to an existing user.
  def user_grant_role(user, role)
    request.handle(:auth, 'user_grant_role', [user, role])
  end

  # Revokes role from a specified user.
  def user_revoke_role(user, role)
    request.handle(:auth, 'user_revoke_role', [user, role])
  end

  # Watches for changes on a specified key range.
  def watch(key, range_end: '', &block)
    request.handle(:watch, 'watch', [key, range_end, block])
  end

  def transaction(&block)
    request.handle(:kv, 'transaction', [block])
  end

  private

  def request(reset: false)
    return @request if @request && !reset
    @request = Request.new("#{hostname}:#{port}", @credentials)
  end

  def resolve_credentials
    case scheme
    when 'http'
      :this_channel_is_insecure
    when 'https'
      GRPC::Core::ChannelCredentials.new(*tls_creds)
    else
      raise "Unknown scheme: #{scheme}"
    end
  end
end
