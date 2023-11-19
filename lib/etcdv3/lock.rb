class Etcdv3
  class Lock
    include GRPC::Core::TimeConsts

    def initialize(hostname, credentials, timeout, metadata = {}, grpc_options = {})
      @stub = V3lockpb::Lock::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @metadata = metadata
    end

    def lock(name, lease_id, timeout: nil)
      request = V3lockpb::LockRequest.new(name: name, lease: lease_id)
      @stub.lock(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def unlock(key, timeout: nil)
      request = V3lockpb::UnlockRequest.new(key: key)
      @stub.unlock(request, metadata: @metadata, deadline: deadline(timeout))
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
