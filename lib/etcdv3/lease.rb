
class Etcdv3
  class Lease
    def initialize(hostname, credentials, metadata={})
      @stub = Etcdserverpb::Lease::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def lease_grant(ttl)
      request = Etcdserverpb::LeaseGrantRequest.new(TTL: ttl)
      @stub.lease_grant(request, metadata: @metadata)
    end

    def lease_revoke(id)
      request = Etcdserverpb::LeaseRevokeRequest.new(ID: id)
      @stub.lease_revoke(request, metadata: @metadata)
    end

    def lease_ttl(id)
      request = Etcdserverpb::LeaseTimeToLiveRequest.new(ID: id, keys: true)
      @stub.lease_time_to_live(request, metadata: @metadata)
    end

    def lease_keep_alive(ids)
      requests = ids.map do |id|
        Etcdserverpb::LeaseKeepAliveRequest.new ID: id
      end

      @stub.lease_keep_alive(requests)
    end


  end
end
