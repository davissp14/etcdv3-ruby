class Etcdv3
  class Lease
    include GRPC::Core::TimeConsts

    def initialize(hostname, credentials, timeout, metadata={}, grpc_options={})
      @stub = Etcdserverpb::Lease::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @metadata = metadata
    end

    def lease_grant(ttl, timeout: nil)
      request = Etcdserverpb::LeaseGrantRequest.new(TTL: ttl)
      @stub.lease_grant(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def lease_revoke(id, timeout: nil)
      request = Etcdserverpb::LeaseRevokeRequest.new(ID: id)
      @stub.lease_revoke(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def lease_ttl(id, timeout: nil)
      request = Etcdserverpb::LeaseTimeToLiveRequest.new(ID: id, keys: true)
      @stub.lease_time_to_live(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def lease_keep_alive_once(id, timeout: nil)
      request = Etcdserverpb::LeaseKeepAliveRequest.new(ID: id)
      @stub.lease_keep_alive([request], metadata: @metadata, deadline: deadline(timeout)).each do |resp|
        return resp
      end
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
