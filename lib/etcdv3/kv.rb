
class Etcd
  class KV
    def initialize(hostname, credentials, metadata={})
      @stub = Etcdserverpb::KV::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def put(key, value, lease=nil)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      kv.lease = lease if lease
      @stub.put(kv, metadata: @metadata)
    end

    def get(key, range_end="")
      kv = Etcdserverpb::RangeRequest.new(key: key, range_end: range_end)
      @stub.range(kv, metadata: @metadata)
    end

    def del(key, range_end="")
      request = Etcdserverpb::DeleteRangeRequest.new(
        key: key,
        range_end: range_end
      )
      @stub.delete_range(request, metadata: @metadata)
    end
  end
end
