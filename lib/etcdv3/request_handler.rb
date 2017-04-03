
class Etcd
  class RequestHandler

    def initialize(target, uri, creds, metadata)
      @stub = target::STUB.new(uri, creds)
      @metadata = metadata
      self.class.include(target)
    end

    def resolve_request(const, target, attributes: {}, auth: true )
      const = Object.const_get("Etcdserverpb::#{req}")
      request = const.new(attributes)
      if auth
        @stub.send(target, request, metadata: @metadata)
      else
        @stub.send(target, request)
      end
    end
  end
end
