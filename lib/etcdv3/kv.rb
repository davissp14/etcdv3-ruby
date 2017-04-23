
class Etcdv3
  class KV
    include Etcdv3::KV::Requests

    def initialize(hostname, credentials, metadata={})
      @stub = Etcdserverpb::KV::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def get(key, opts={})
      @stub.range(get_request(key, opts), metadata: @metadata)
    end

    def del(key, range_end="")
      @stub.delete_range(del_request(key, range_end), metadata: @metadata)
    end

    def put(key, value, lease=nil)
      @stub.put(put_request(key, value, lease), metadata: @metadata)
    end

    def transaction(block)
      txn = Etcdv3::KV::Transaction.new
      block.call(txn)
      request = Etcdserverpb::TxnRequest.new(
        compare: txn.compare,
        success: generate_request_ops(txn.success),
        failure: generate_request_ops(txn.failure)
      )
      @stub.txn(request)
    end

    private

    def generate_request_ops(requests)
      requests.map do |request|
        if request.is_a?(Etcdserverpb::RangeRequest)
          Etcdserverpb::RequestOp.new(request_range: request)
        elsif request.is_a?(Etcdserverpb::PutRequest)
          Etcdserverpb::RequestOp.new(request_put: request)
        elsif request.is_a?(Etcdserverpb::DeleteRangeRequest)
          Etcdserverpb::RequestOp.new(request_delete_range: request)
        else
          raise "Invalid command. Not sure how you got here!"
        end
      end
    end
  end
end
