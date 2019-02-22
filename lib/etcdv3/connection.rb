class Etcdv3
  class Connection

    HANDLERS = {
      auth: Etcdv3::Auth,
      kv: Etcdv3::KV,
      maintenance: Etcdv3::Maintenance,
      lease: Etcdv3::Lease,
      watch: Etcdv3::Watch,
      lock: Etcdv3::Lock,
    }

    attr_reader :endpoint, :hostname, :handlers, :credentials

    def initialize(url, timeout, metadata={}, custom_certificates=nil)
      @endpoint = URI(url)
      @hostname = "#{@endpoint.hostname}:#{@endpoint.port}"
      @credentials = resolve_credentials(custom_certificates)
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

    def resolve_credentials(custom_certificates)
      case @endpoint.scheme
      when 'http'
        :this_channel_is_insecure
      when 'https'
        # Use default certs for now.
        return GRPC::Core::ChannelCredentials.new if custom_certificates.nil?

        GRPC::Core::ChannelCredentials.new(
          File.read(custom_certificates[:root_ca]),
          File.read(custom_certificates[:key]),
          File.read(custom_certificates[:cert])
        )
      else
        raise "Unknown scheme: #{@endpoint.scheme}"
      end
    end
  end
end
