class Etcdv3::Namespace::KV
  module Requests

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

    def get_request(key, opts)
      key = prepend_prefix(@namespace, key)
      opts[:range_end] = prepend_prefix(@namespace, opts[:range_end]) \
        if opts[:range_end]
      opts[:sort_order] = SORT_ORDER[opts[:sort_order]] \
        if opts[:sort_order]
      opts[:sort_target] = SORT_TARGET[opts[:sort_target]] \
        if opts[:sort_target]
      opts[:key] = key
      Etcdserverpb::RangeRequest.new(opts)
    end

    def del_request(key, range_end=nil)
      key = prepend_prefix(@namespace, key)
      range_end = prepend_prefix(@namespace, range_end) unless range_end
      Etcdserverpb::DeleteRangeRequest.new(key: key, range_end: range_end)
    end

    def put_request(key, value, lease=nil)
      key = prepend_prefix(@namespace, key)
      kv = Etcdserverpb::PutRequest.new(key: key, value: value)
      kv.lease = lease if lease
      kv
    end
  end
end
