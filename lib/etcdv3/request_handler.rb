
class Etcd
  class RequestHandler
    class TimeoutException < StandardError; end

    include Etcd::Auth
    include Etcd::KV
    include Etcd::Maintenance

    def initialize(target, uri, creds, metadata)
      @stub = target::STUB.new(uri, creds)
      @metadata = metadata
    end

    def resolve_request(req, target, attributes: {}, auth: true, timeout: 5)
      const = Object.const_get("Etcdserverpb::#{req}")
      request = const.new(attributes)
      if auth
        @stub.send(target, request, metadata: @metadata)
      else
        @stub.send(target, request)
      end
    rescue GRPC::Unavailable => exception
      # Could potentially put auto-reconnect logic here...
    end
  end
end
