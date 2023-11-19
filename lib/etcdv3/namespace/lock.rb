class Etcdv3::Namespace
  class Lock
    include GRPC::Core::TimeConsts
    include Etcdv3::Namespace::Utilities

    def initialize(hostname, credentials, timeout, namespace, metadata = {}, grpc_options = {})
      @stub = V3lockpb::Lock::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @namespace = namespace
      @metadata = metadata
    end

    def lock(name, lease_id, timeout: nil)
      name = prepend_prefix(@namespace, name)
      request = V3lockpb::LockRequest.new(name: name, lease: lease_id)
      resp = @stub.lock(request, metadata: @metadata, deadline: deadline(timeout))
      strip_prefix_from_lock(@namespace, resp)
    end

    def unlock(key, timeout: nil)
      key = prepend_prefix(@namespace, key)
      request = V3lockpb::UnlockRequest.new(key: key)
      @stub.unlock(request, metadata: @metadata, deadline: deadline(timeout))
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
