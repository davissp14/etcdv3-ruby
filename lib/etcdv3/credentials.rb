class Etcdv3
  class Credentials
    class FailedToResolveCredentials < StandardError; end

    def initialize(key: nil, cert: nil, cacert: nil)
      @key = resolve_key(key)
      @cert = resolve_cert(cert)
      @cacert = resolve_cacert(cacert)
    end

    # Uses the endpoint URI to determine whether we should use a secure
    # channel or not.
    def resolve(endpoint)
      case endpoint.scheme
      when 'http'
        :this_channel_is_insecure
      when 'https'
        GRPC::Core::ChannelCredentials.new(*tls_creds)
      else
        raise "Unknown scheme: #{endpoint.scheme}"
      end
    end

    private

    def resolve_key(key)
      return nil unless key
      File.read(File.expand_path(key))
    rescue Errno::ENOENT
      raise FailedToResolveCredentials.new("Unable to resolve `key`: #{key}")
    end

    def resolve_cert(cert)
      return nil unless cert
      File.read(File.expand_path(cert))
    rescue Errno::ENOENT
      raise FailedToResolveCredentials.new("Unable to resolve `cert`: #{cert}")
    end

    def resolve_cacert(cacert)
      return nil unless cacert
      File.read(File.expand_path(cacert))
    rescue Errno::ENOENT
      raise FailedToResolveCredentials.new("Unable to resolve `cacert`: #{cacert}")
    end

    def tls_creds
      [@cacert, @key, @cert]
    end
  end
end
