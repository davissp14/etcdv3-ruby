
require 'grpc'
require 'uri'

require 'etcd/etcdrpc/rpc_services_pb'
require 'etcd/auth'
require 'etcd/kv'

class Etcd

  def options
    Marshal.load(Martial.dump(@options))
  end

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
    @options[:user]
  end

  def password
    @options[:password]
  end

  def token
    @metadata[:token]
  end

  def credentials
    @credentials
  end

  def initialize(options={})
    @options = options
    @credentials = resolve_credentials
    @metadata = {}
    unless user.nil?
      @metadata[:token] = auth.generate_token(user, password)
    end
  end

  def put(key, value)
    kv.put(key, value, @metadata)
  end

  def range(key, range_end)
    kv.range(key, range_end, @metadata)
  end

  private

  def auth
    Etcd::Auth.new(hostname, port, @credentials)
  end

  def kv
    Etcd::KV.new(hostname, port, @credentials)
  end

  def resolve_credentials
    case scheme
    when "http"
      :this_channel_is_insecure
    when "https"
      # Use default certs for now.
      GRPC::Core::ChannelCredentials.new
    else
      raise "Unknown scheme: #{scheme}"
    end
  end
end
