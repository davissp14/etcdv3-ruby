
require 'grpc'
require 'uri'

require 'etcdv3/etcdrpc/rpc_services_pb'
require 'etcdv3/auth'
require 'etcdv3/kv'
require 'etcdv3/maintenance'

class Etcd

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
    @metadata[:token] = auth.generate_token(user, password) unless user.nil?
  end

  # Version of Etcd running on member
  def version
    maintenance.status.version
  end

  # Store size in bytes.
  def db_size
    maintenance.status.dbSize
  end

  # Cluster leader id
  def leader_id
    maintenance.status.leader
  end

  # Inserts a new key.
  def put(key, value)
    kv.put(key, value)
  end

  # Fetches key(s).
  def get(key, range_end='')
    kv.get(key, range_end)
  end

  # Creates new user.
  def add_user(user, password)
    auth.add_user(user, password)
  end

  # Fetch specified user
  def get_user(user)
    auth.get_user(user)
  end

  # Delete specified user.
  def delete_user(user)
    auth.delete_user(user)
  end

  # Changes the specified users password.
  def change_user_password(user, new_password)
    auth.change_user_password(user, new_password)
  end

  # List all users.
  def user_list
    auth.user_list
  end

  # Authenticate using specified user and password.
  # On successful authentication, an auth token will be assigned to the instance.
  def authenticate(user, password)
    token = auth.generate_token(user, password)
    return false unless token
    @metadata[:token] = token
    @options[:user] = user
    @options[:password] = password

    true
  end

  # List all roles.
  def role_list
    auth.role_list
  end

  # Add role with specified name.
  def add_role(name)
    auth.add_role(name)
  end

  # Fetches a specified role.
  def get_role(name)
    auth.get_role(name)
  end

  # Delete role.
  def delete_role(name)
    auth.delete_role(name)
  end

  # Grants role to an existing user.
  def grant_role_to_user(user, role)
    auth.grant_role_to_user(user, role)
  end

  # Revokes role from a specified user.
  def revoke_role_from_user(user, role)
    auth.revoke_role_from_user(user, role)
  end

  # Grants a new permission to an existing role.
  def grant_permission_to_role(name, permission, key, range_end='')
    auth.grant_permission_to_role(name, permission, key, range_end)
  end

  def revoke_permission_from_role(name, permission, key, range_end='')
    auth.revoke_permission_from_role(name, permission, key, range_end)
  end

  # Enables authentication.
  def enable_auth
    auth.enable_auth
  end

  # Disables authentication.
  # This will clear any active auth / token data.
  def disable_auth
    response = auth.disable_auth
    if response
      @metadata.delete(:token)
      @options[:user] = nil
      @options[:password] = nil
    end
    response
  end

  private

  def auth
    Etcd::Auth.new(hostname, port, @credentials, @metadata)
  end

  def kv
    Etcd::KV.new(hostname, port, @credentials, @metadata)
  end

  def maintenance
    Etcd::Maintenance.new(hostname, port, @credentials, @metadata)
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
