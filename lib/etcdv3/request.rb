class Etcd
  class Request

    attr_reader :metacache

    def initialize(hostname, credentials, metadata, metacache)
      @hostname = hostname
      @credentials = credentials
      @metadata = metadata
      @metacache = metacache
    end

    def handle(interface, method, method_args=[])
      interface = resolve_interface(interface)
      interface.send(method, *method_args)
    end

    private

    def resolve_interface(interface)
      self.send(interface)
    end

    def auth
      @auth ||= Etcd::Auth.new(@hostname, @credentials, @metadata)
    end

    def kv
      @kv ||= Etcd::KV.new(@hostname, @credentials, @metadata)
    end

    def maintenance
      @maintenance ||= Etcd::Maintenance.new(@hostname, @credentials, @metadata)
    end

    def lease
      @lease ||= Etcd::Lease.new(@hostname, @credentials, @metadata)
    end

  end
end
