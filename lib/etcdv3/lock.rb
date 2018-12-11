class Etcdv3
  class Lock
    include GRPC::Core::TimeConsts

    def initialize(hostname, credentials, timeout, metadata = {})
      @stub = V3lockpb::Lock::Stub.new(hostname, credentials)
      @timeout = timeout
      @metadata = metadata
    end

    def lock(name, timeout: nil)
      request = V3lockpb::LockRequest.new(name: name)
      @stub.lock(request, deadline: deadline(timeout))
    end

    def unlock(key, timeout: nil)
      request = V3lockpb::UnlockRequest.new(key: key)
      @stub.unlock(request, deadline: deadline(timeout))
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
