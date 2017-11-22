class Etcdv3
  class Connection

    HANDLERS = {
      auth: Etcdv3::Auth,
      kv: Etcdv3::KV,
      maintenance: Etcdv3::Maintenance,
      lease: Etcdv3::Lease,
      watch: Etcdv3::Watch
    }.freeze

    attr_reader :endpoint, :handlers, :credentials, :timeout

    def initialize(url, credentials, timeout, metadata = {})
      @endpoint = URI(url)
      @credentials = credentials.resolve(@endpoint)
      @timeout = timeout
      @handlers = handler_map(metadata)
    end

    def call(stub, method, method_args)
      @handlers.fetch(stub).send(method, *method_args)
    end

    def refresh_metadata(metadata)
      @handlers = handler_map(metadata)
    end

    def hostname
      "#{@endpoint.hostname}:#{@endpoint.port}"
    end

    private

    def handler_map(metadata)
      Hash[
        HANDLERS.map do |key, klass|
          [key, klass.new(hostname, @credentials, @timeout, metadata)]
        end
      ]
    end
  end
end
