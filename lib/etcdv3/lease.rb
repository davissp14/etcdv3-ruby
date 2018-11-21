class Etcdv3
  class Lease

    # this is used for gRPC proxy compatibility so that we do not
    # mark as finished writing until we've received a response
    class BlockingRequest
      def initialize(request_op)
        @blocked = false
        @request_op = request_op
      end

      def read_done!
        @proceed = true
      end

      def blocked?
        @blocked
      end

      def each
        @blocked = true

        yield @request_op

        sleep 0.001 until @proceed == true
        @blocked = false
      end
    end

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

    def lease_keep_alive_once(id, timeout: nil)
      request = BlockingRequest.new Etcdserverpb::LeaseKeepAliveRequest.new(ID: id)
      response = nil
      begin
        @stub.lease_keep_alive(request, metadata: @metadata, deadline: deadline(timeout)).each do |resp|
          response = resp
          break;
        end
      ensure
        request.read_done!
        while request.blocked?
          sleep 0.001
        end
      end
      return response
    end

    private

    def deadline(timeout)
      Time.now.to_f + (timeout || @timeout)
    end
  end
end
