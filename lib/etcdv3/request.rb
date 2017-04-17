class Etcdv3
  class Request

    attr_reader :metacache

    def initialize(hostname, credentials, metadata, metacache='')
      @handlers ||= handler_map(hostname, credentials, metadata)
      @metacache = metacache
    end

    def handle(stub, method, method_args=[])
      @handlers.fetch(stub).send(method, *method_args)
    end

    private

    def handler_map(hostname, credentials, metadata)
      Hash[
        handler_constants.map do |key, klass|
          [key, klass.new(hostname, credentials, metadata)]
        end
      ]
    end

    def handler_constants
      {
        auth: Etcdv3::Auth,
        kv: Etcdv3::KV,
        maintenance: Etcdv3::Maintenance,
        lease: Etcdv3::Lease,
        watch: Etcdv3::Watch
      }
    end
  end
end
