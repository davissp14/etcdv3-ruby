
class Etcd
  class KV

    def initialize(hostname, port, credentials)
      @stub = Etcdserverpb::KV::Stub.new("#{hostname}:#{port}", credentials)
    end

    def put(key, value, metadata)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      @stub.put(kv, metadata: metadata)
    end

    def range(key, range_end, metadata)
      kv = Etcdserverpb::RangeRequest.new(key: key, range_end: range_end)
      result = @stub.range(kv, metadata: metadata)
      result.kvs
    end

  end
end
