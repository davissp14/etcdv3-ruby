
class Etcdv3
  class KV
    include Etcdv3::KV::Requests
    include GRPC::Core::TimeConsts

    def initialize(hostname, credentials, timeout, metadata={}, grpc_options={})
      @stub = Etcdserverpb::KV::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @metadata = metadata
    end

    def get(key, opts={})
      timeout = opts.delete(:timeout)
      @stub.range(get_request(key, opts), metadata: @metadata, deadline: deadline(timeout))
    end

    def del(key, range_end: '', timeout: nil)
      @stub.delete_range(del_request(key, range_end), metadata: @metadata, deadline: deadline(timeout))
    end

    def put(key, value, lease: nil, timeout: nil)
      @stub.put(put_request(key, value, lease), metadata: @metadata, deadline: deadline(timeout))
    end

    def transaction(block, timeout: nil)
      txn = Etcdv3::KV::Transaction.new
      block.call(txn)
      request = Etcdserverpb::TxnRequest.new(
        compare: txn.compare,
        success: generate_request_ops(txn.success),
        failure: generate_request_ops(txn.failure)
      )
      @stub.txn(request, metadata: @metadata, deadline: deadline(timeout))
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end

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
