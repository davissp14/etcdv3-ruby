class Etcdv3
  class KeepAlive
    def initialize(stub,
                   lease_id,
                   refresh_padding: 10,
                   listener: nil)
      @lease_id = id
      @refresh_padding = refresh_padding
      @q = EnumeratorQueue.new
      @responses = @stub.lease_keep_alive(@q)

      # Session listener that can receive messages
      # like:
      #   1. on_open - called when the session opens
      #   2. on_error - called when the session errors for some reason
      #   3. on_close - called when the session is closed by user
      @listener = listener
      @lock = Monitor.new

      @response_thread = Thread.new do
        begin
          @responses.each do |_|
            # Do nothing
          end
        rescue => e
          on_error(e)
        end

        on_close
      end

      @keep_alive_thread = Thread.new do
      end
    end

    def cancel
      @q.cancel
    end
  end

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

    # This will keep the lease alive for
    # as long as the stream is kept open
    #
    # Returns a LeaseKeepAlive
    # Call close to close the stream and stop
    # refreshing the lease
    #
    # id - the id of the lease to keep alive
    # keep_alive_padding - how much padding to give to the refresh calls
    #   if the TTL of the lease is 60 seconds and the refresh_padding
    #   is 10 seconds, then a lease keep alive request will be
    #   sent to the server every 50 seconds. refresh_padding must
    #   be at least 1 second and at most 1 second less than the TTL.
    # listener - object that receives lifetime hooks
    def lease_keep_alive(id,
                         keep_alive_padding: LeaseKeepAlive::DEFAULT_KEEP_ALIVE_PADDING,
                         listener: nil)
      LeaseKeepAlive.new(@stub,
                         id,
                         keep_alive_padding: keep_alive_padding,
                         listener: listener)
    end


  end
end
