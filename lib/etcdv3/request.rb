class Etcdv3
  class Request

    attr_reader :metacache

    def initialize(hostname, credentials, metadata, metacache)
      @hostname = hostname
      @credentials = credentials
      @metadata = metadata
      @metacache = metacache
    end

    def handle(interface, method, method_args=[], &block)
      interface = resolve_interface(interface)
      interface.send(method, *method_args, &block)
    end

    private

    def resolve_interface(interface)
      self.send(interface)
    end

    def auth
      @auth ||= Etcdv3::Auth.new(@hostname, @credentials, @metadata)
    end

    def kv
      @kv ||= Etcdv3::KV.new(@hostname, @credentials, @metadata)
    end

    def maintenance
      @maintenance ||= Etcdv3::Maintenance.new(@hostname, @credentials, @metadata)
    end

    def lease
      @lease ||= Etcdv3::Lease.new(@hostname, @credentials, @metadata)
    end

    def watch
      @watch ||= Etcdv3::Watch.new(@hostname, @credentials, @metadata)
    end

  end
end
