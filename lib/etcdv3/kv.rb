
class Etcd
  class KV
    def initialize(hostname, port, credentials, metadata={})
      @stub = Etcdserverpb::KV::Stub.new("#{hostname}:#{port}", credentials)
      @metadata = metadata
    end

    def put(key, value)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      @stub.put(kv, metadata: @metadata)
    end

    def get(key, range_end="")
      kv = Etcdserverpb::RangeRequest.new(key: key, range_end: range_end)
      @stub.range(kv, metadata: @metadata).kvs
    end
  end
end
