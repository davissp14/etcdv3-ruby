
class Etcd
  module KV
    STUB = Etcdserverpb::KV::Stub

    def put(key, value)
      resolve_request('PutRequest', 'put',
        attributes: {
          key: key,
          value: value
        }
      )
    end

    def get(key, range_end="")
      resolve_request('RangeRequest', 'range',
        attributes: {
          key: key,
          range_end: range_end
        }
      ).kvs
    end

  end
end
