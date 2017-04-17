
class Etcdv3
  class KV

    SORT_TARGET = {
      key: 0,
      version: 1,
      create: 2,
      mod: 3,
      value: 4
    }

    SORT_ORDER = {
      none: 0,
      ascend: 1,
      descend: 2
    }

    def initialize(hostname, credentials, metadata={})
      @stub = Etcdserverpb::KV::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def get(key, opts={})
      opts[:sort_order] = SORT_ORDER[opts[:sort_order]] \
        if opts[:sort_order]
      opts[:sort_target] = SORT_TARGET[opts[:sort_target]] \
        if opts[:sort_target]
      opts[:key] = key
      kv = Etcdserverpb::RangeRequest.new(opts)
      @stub.range(kv, metadata: @metadata)
    end

    def del(key, range_end="")
      request = Etcdserverpb::DeleteRangeRequest.new(
        key: key,
        range_end: range_end
      )
      @stub.delete_range(request, metadata: @metadata)
    end

    def put(key, value, lease=nil)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      kv.lease = lease if lease
      @stub.put(kv, metadata: @metadata)
    end
  end
end
