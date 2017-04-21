class Etcdv3::KV
  class Transaction
    include Etcdv3::KV::Requests

    # Available comparison identifiers.
    COMPARISON_IDENTIFIERS = {
      equal: 0,
      greater: 1,
      less: 2,
      not_equal: 3
    }

    # Available targets to compare with.
    TARGETS = {
      version: 0,
      create_revision: 1,
      mod_revision: 2,
      value: 3
    }

    attr_writer :compare, :success, :failure

    def initialize; end

    def compare
      @compare ||= []
    end

    def success
      @success ||= []
    end

    def failure
      @failure ||=[]
    end

    # Request Operations

    # txn.put('my', 'key')
    def put(key, value)
      put_request(key, value)
    end

    # txn.get('key')
    def get(key, opts={})
      get_request(key, opts)
    end

    # txn.del('key')
    def del(key, opts={})
      del_request(key, opts)
    end

    ###  Compare Operations

    # txn.version('names', :greater, 0 )
    def version(key, compare_type, value)
      generate_compare(:version, key, compare_type, value)
    end

    # txn.value('names', :equal, 'wowza' )
    def value(key, compare_type, value)
      generate_compare(:value, key, compare_type, value)
    end

    # txn.mod_revision('names', :not_equal, 0)
    def mod_revision(key, compare_type, value)
      generate_compare(:mod_revision, key, compare_type, value)
    end

    # txn.create_revision('names', :less, 10)
    def create_revision(key, compare_type, value)
      generate_compare(:create_revision, key, compare_type, value)
    end

    private

    def generate_compare(target_union, key, compare_type, value)
      Etcdserverpb::Compare.new(
        key: key,
        result: COMPARISON_IDENTIFIERS[compare_type],
        target: TARGETS[target_union],
        target_union => value
      )
    end
  end
end
