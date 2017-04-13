
require 'grpc'
require 'uri'
require 'base64'

require 'etcdv3/etcdrpc/rpc_services_pb'
require 'etcdv3/auth'
require 'etcdv3/kv'
require 'etcdv3/maintenance'
require 'etcdv3/lease'
require 'etcdv3/request'
require 'etcdv3/watch'

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

  def token
    @metadata[:token]
  end

  def user
    @options[:user]
  end

  def password
    @options[:password]
  end

  def initialize(options = {})
    @options = options
    @credentials = resolve_credentials
    @metadata = {}
    @metadata[:token] = generate_token(user, password) unless user.nil?
    @metacache = set_metacache
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

  # Watches for changes on a specified key range.
  def watch(key, range_end: '', &block)
    request.handle(:watch, 'watch', [key, range_end, block])
  end

  # List active alarms
  def alarm_list
    request.handle(:maintenance, 'alarms', [:get, leader_id])
  end

  # Disarm alarms on a specified member.
  def deactivate_alarms
    request.handle(:maintenance, 'alarms', [:deactivate, leader_id])
  end

  # Inserts a new key.
  def put(key, value, lease_id: nil)
    request.handle(:kv, 'put', [key, value, lease_id])
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

  # Deletes a specified key
  def del(key, range_end: '')
    request.handle(:kv, 'del', [key, range_end])
  end

  # Grant a lease with a specified TTL
  def grant_lease(ttl)
    request.handle(:lease, 'grant_lease', [ttl])
  end

  # Revokes lease and delete all attached keys
  def revoke_lease(id)
    request.handle(:lease, 'revoke_lease', [id])
  end

  # Returns information regarding the current state of the lease
  def lease_ttl(id)
    request.handle(:lease, 'lease_ttl', [id])
  end

  # Creates new user.
  def add_user(user, password)
    request.handle(:auth, 'add_user', [user, password])
  end

  # Fetch specified user
  def get_user(user)
    request.handle(:auth, 'get_user', [user])
  end

  # Delete specified user.
  def delete_user(user)
    request.handle(:auth, 'delete_user', [user])
  end

  # Changes the specified users password.
  def change_user_password(user, new_password)
    request.handle(:auth, 'change_user_password', [user, new_password])
  end

  # List all users.
  def user_list
    request.handle(:auth, 'user_list')
  end

  # List all roles.
  def role_list
    request.handle(:auth, 'role_list')
  end

  # Add role with specified name.
  def add_role(name)
    request.handle(:auth, 'add_role', [name])
  end

  # Fetches a specified role.
  def get_role(name)
    request.handle(:auth, 'get_role', [name])
  end

  # Delete role.
  def delete_role(name)
    request.handle(:auth, 'delete_role', [name])
  end

  # Grants role to an existing user.
  def grant_role_to_user(user, role)
    request.handle(:auth, 'grant_role_to_user', [user, role])
  end

  # Revokes role from a specified user.
  def revoke_role_from_user(user, role)
    request.handle(:auth, 'revoke_role_from_user', [user, role])
  end

  # Grants a new permission to an existing role.
  def grant_permission_to_role(name, permission, key, range_end='')
    request.handle(:auth, 'grant_permission_to_role', [name, permission, key, range_end])
  end

  def revoke_permission_from_role(name, permission, key, range_end='')
    request.handle(:auth, 'revoke_permission_from_role', [name, permission, key, range_end])
  end

  # Enables authentication.
  def enable_auth
    request.handle(:auth, 'enable_auth')
  end

  # Disables authentication.
  # This will clear any active auth / token data.
  def disable_auth
    response = request.handle(:auth, 'disable_auth')
    if response
      @metadata.delete(:token)
      @options[:user] = nil
      @options[:password] = nil
      @metacache = set_metacache
    end
    response
  end

  # Authenticate using specified user and password.
  # On successful authentication, an auth token will be assigned to the instance.
  def authenticate(user, password)
    token = generate_token(user, password)
    return false unless token
    @metadata[:token] = token
    @options[:user] = user
    @options[:password] = password
    @metacache = set_metacache

    true
  end

  private

  def request
    # Only re-initialize when metadata changes.
    return @request if @request && @request.metacache == @metacache
    @request = Request.new("#{hostname}:#{port}", @credentials, @metadata, @metacache)
  end

  # Generates a new hash using a base64 of the metadata.
  def set_metacache
    Base64.strict_encode64(@metadata.to_s)
  end

  def generate_token(user, password)
    request.handle(:auth, 'generate_token', [user, password])
  end

  def resolve_credentials
    case scheme
    when 'http'
      :this_channel_is_insecure
    when 'https'
      # Use default certs for now.
      GRPC::Core::ChannelCredentials.new
    else
      raise "Unknown scheme: #{scheme}"
    end
  end
end
