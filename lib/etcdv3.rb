
require 'grpc'
require 'uri'

require 'etcdv3/etcdrpc/rpc_services_pb'
require 'etcdv3/auth'
require 'etcdv3/kv'

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

  def put(key, value)
    kv.put(key, value)
  end

  def get(key, range_end='')
    kv.get(key, range_end)
  end

  def add_user(user, password)
    auth.add_user(user, password)
  end

  def delete_user(user)
    auth.delete_user(user)
  end

  def user_list
    auth.user_list
  end

  def authenticate(user, password)
    token = auth.generate_token(user, password)
    if token
      @metadata[:token] = token
      @options[:user] = user
      @options[:password] = password
      return true
    end
  rescue GRPC::InvalidArgument => exception
    print exception.message
    return false
  end

  def role_list
    auth.role_list
  end

  def add_role(name, permission, key, range_end='')
    auth.add_role(name, permission, key, range_end)
  end

  def delete_role(name)
    auth.delete_role(name)
  end

  def grant_role_to_user(user, role)
    auth.grant_role_to_user(user, role)
  end

  def enable_auth
    auth.enable_auth
  end

  def disable_auth
    auth.disable_auth
  end

  private

  def auth
    Etcd::Auth.new(hostname, port, @credentials, @metadata)
  end

  def kv
    Etcd::KV.new(hostname, port, @credentials, @metadata)
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
