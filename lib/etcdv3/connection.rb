class Etcdv3
  class Connection

    HANDLERS = {
      auth: Etcdv3::Auth,
      kv: Etcdv3::KV,
      maintenance: Etcdv3::Maintenance,
      lease: Etcdv3::Lease,
      watch: Etcdv3::Watch
    }

    attr_reader :endpoint, :hostname, :handlers, :credentials

    def initialize(url, timeout, metadata={})
      @endpoint = URI(url)
      @hostname = "#{@endpoint.hostname}:#{@endpoint.port}"
      @credentials = resolve_credentials
      @timeout = timeout
      @handlers = handler_map(metadata)
    end

    def call(stub, method, method_args=[])
      @handlers.fetch(stub).send(method, *method_args)
    end

    def refresh_metadata(metadata)
      @handlers = handler_map(metadata)
    end

    private

    def handler_map(metadata={})
      Hash[
        HANDLERS.map do |key, klass|
          [key, klass.new("#{@hostname}", @credentials, @timeout, metadata)]
        end
      ]
    end

    def resolve_credentials
      case @endpoint.scheme
      when 'http'
        :this_channel_is_insecure
      when 'https'
        # Use default certs for now.
        GRPC::Core::ChannelCredentials.new
      else
        raise "Unknown scheme: #{@endpoint.scheme}"
      end
    end
  end
end
