class Etcdv3
  class Connection

    NAMESPACE_HANDLERS = {
      kv: Etcdv3::Namespace::KV,
      watch: Etcdv3::Namespace::Watch,
      lock: Etcdv3::Namespace::Lock,
    }

    HANDLERS = {
      auth: Etcdv3::Auth,
      kv: Etcdv3::KV,
      maintenance: Etcdv3::Maintenance,
      lease: Etcdv3::Lease,
      watch: Etcdv3::Watch,
      lock: Etcdv3::Lock,
    }

    attr_reader :endpoint, :hostname, :handlers, :credentials, :namespace

    def initialize(url, timeout, namespace, metadata={}, grpc_options={})
      @endpoint = URI(url)
      @hostname = "#{@endpoint.hostname}:#{@endpoint.port}"
      @namespace = namespace
      @credentials = resolve_credentials
      @timeout = timeout
      @grpc_options = grpc_options
      @handlers = handler_map(metadata)
    end

    def call(stub, method, method_args=[])
      *method_args, method_kwargs = method_args if method_args.last.class == Hash

      if method_kwargs.nil?
        @handlers.fetch(stub).send(method, *method_args)
      else
        @handlers.fetch(stub).send(method, *method_args, **method_kwargs)
      end
    end

    def refresh_metadata(metadata)
      @handlers = handler_map(metadata)
    end

    private

    def handler_map(metadata={})
      handlers = Hash[
        HANDLERS.map do |key, klass|
          [key, klass.new(@hostname, @credentials, @timeout, metadata, @grpc_options)]
        end
      ]
      # Override any handlers that are namespace compatable.
      if @namespace
        NAMESPACE_HANDLERS.each do |key, klass|
          handlers[key] = klass.new(@hostname, @credentials, @timeout, @namespace, metadata, @grpc_options)
        end
      end
      
      handlers
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
