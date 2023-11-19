class Etcdv3::Namespace
  class KV
    include Etcdv3::Namespace::KV::Requests
    include Etcdv3::Namespace::Utilities
    include GRPC::Core::TimeConsts
  
    def initialize(hostname, credentials, timeout, namespace, metadata={}, grpc_options={})
      @stub = Etcdserverpb::KV::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @namespace = namespace
      @metadata = metadata
    end

    def get(key, opts={})
      timeout = opts.delete(:timeout)
      resp = @stub.range(get_request(key, opts), metadata: @metadata, deadline: deadline(timeout))
      strip_prefix(@namespace, resp)
    end

    def del(key, range_end: '', timeout: nil)
      resp = @stub.delete_range(del_request(key, range_end), metadata: @metadata, deadline: deadline(timeout))
      strip_prefix(@namespace, resp)
    end

    def put(key, value, lease: nil, timeout: nil)
      resp = @stub.put(put_request(key, value, lease), metadata: @metadata, deadline: deadline(timeout))
      strip_prefix(@namespace, resp)
    end

    def transaction(block, timeout: nil)
      txn = Etcdv3::Namespace::KV::Transaction.new(@namespace)
      block.call(txn)
      request = Etcdserverpb::TxnRequest.new(
        compare: txn.compare,
        success: generate_request_ops(txn.success),
        failure: generate_request_ops(txn.failure),
      )
      resp = @stub.txn(request, metadata: @metadata, deadline: deadline(timeout))
      strip_prefix(@namespace, resp)
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
