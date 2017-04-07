
class Etcd
  class Lease
    def initialize(hostname, credentials, metadata={})
      @stub = Etcdserverpb::Lease::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def grant_lease(ttl)
      request = Etcdserverpb::LeaseGrantRequest.new(TTL: ttl)
      @stub.lease_grant(request, metadata: @metadata)
    end

    def revoke_lease(id)
      request = Etcdserverpb::LeaseRevokeRequest.new(ID: id)
      @stub.lease_revoke(request, metadata: @metadata)
    end

    def lease_ttl(id)
      request = Etcdserverpb::LeaseTimeToLiveRequest.new(ID: id, keys: true)
      @stub.lease_time_to_live(request, metadata: @metadata)
    end

  end
end
