class Etcdv3::KV
  module Requests

    def get_request(key, opts)
      opts[:sort_order] = SORT_ORDER[opts[:sort_order]] \
        if opts[:sort_order]
      opts[:sort_target] = SORT_TARGET[opts[:sort_target]] \
        if opts[:sort_target]
      opts[:key] = key
      Etcdserverpb::RangeRequest.new(opts)
    end

    def del_request(key, range_end="")
      Etcdserverpb::DeleteRangeRequest.new(key: key, range_end: range_end)
    end

    def put_request(key, value, lease=nil)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      kv.lease = lease if lease
      kv
    end
  end
end
