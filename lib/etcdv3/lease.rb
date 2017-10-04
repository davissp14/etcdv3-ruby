class Etcdv3
  class Lease
    def initialize(hostname, credentials, timeout, metadata={})
      @stub = Etcdserverpb::Lease::Stub.new(hostname, credentials)
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

    private

    def deadline(timeout)
      Time.now.to_f + (timeout || @timeout)
    end
  end
end
