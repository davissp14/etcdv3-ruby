class Etcdv3
    # A session is used to keep a lease alive for the duration
  # of a connection with an etcd3 server.
  #
  # This is useful for implementing functionality, such
  # as distributed locks, where it may be necessary to
  # maintain a lock as long as the connection is alive
  # and well.
  #
  # Session provides a way to hook into events using a
  # listener. This will allow our applications to respond
  # in case we let a lease expire accidentally or there
  # is a connection issue and we need to close the session.
  #
  # Parameters
  # stub - the client stub to send requests to
  # keep_alive_padding - how much padding to give to the refresh calls
  #   if the TTL of the lease is 60 seconds and the refresh_padding
  #   is 10 seconds, then a lease keep alive request will be
  #   sent to the server every 50 seconds. refresh_padding must
  #   be at least 1 second and at most 1 second less than the TTL.
  # lease_ttl - TTL for the lease, defaults to 60 seconds
  # listener - object that receives lifetime hooks
  # lease_id - id of existing lease to take over, this is
  #   useful when passing the lease from an old session
  #   to a new session, such as after authentication
  class LeaseKeepAlive
    MIN_REFRESH_INTERVAL = 5
    MIN_KEEP_ALIVE_PADDING = 5
    DEFAULT_KEEP_ALIVE_PADDING = MIN_KEEP_ALIVE_PADDING

    def initialize(stub,
                   lease_id,
                   keep_alive_padding: DEFAULT_KEEP_ALIVE_PADDING,
                   listener: nil)
      raise "keep_alive_padding must be >= #{MIN_KEEP_ALIVE_PADDING}" unless keep_alive_padding >= MIN_KEEP_ALIVE_PADDING

      # Monitor used to synchronize access to the session
      # we use a Monitor instead of Mutex for reentrancy
      @lock = Monitor.new

      # Session listener that can receive messages
      # like:
      #   1. on_open - called when the session opens
      #   2. on_error - called when the session errors for some reason
      #   3. on_revoke - called when the session is closed and the user wants to recoke the lease
      #   4. on_orphan - called when the lease is orphaned (no longer being kept alive)
      @listener = listener

      # The lease id that we are keeping alive
      @lease_id = lease_id

      # Get the lease TTL
      request = Etcdserverpb::LeaseTimeToLiveRequest.new(ID: id, keys: true)
      @lease_granted_ttl = @stub.lease_time_to_live(request, metadata: @metadata).grantedTTL

      # Set the refresh interval
      @refresh_interval = @lease_granted_ttl - keep_alive_padding

      # Refresh interval must be at least MIN_REFRESH_INTERVAL
      if @refresh_interval < MIN_REFRESH_INTERVAL
        max_refresh_interval = @lease_granted_ttl - MIN_REFRESH_INTERVAL
        raise "keep_alive_padding is too high, must be at most #{max_refresh_interval}"
      end

      # Use this queue object to push keep
      # alive requests to the server
      @q = EnumeratorQueue.new(self)

      # Get the enumerable that comes back
      # with all of the responses from the
      # etcd3 server
      @responses = @stub.lease_keep_alive(@q)

      # We are in the OPEN state until
      # until we close the stream or
      # receive an error
      @state = :OPEN

      # Call on_open of the listener if passed in
      on_open

      # This thread is responsible for monitoring
      # the responses from the server in case
      # something goes wrong
      @response_thread = Thread.new do
        begin
          @responses.each do |_|
            # Don't need to do anything with
            # the responses for now
          end
        rescue => e
          on_error(e)
        end

        on_close
      end

      # This thread is responsible for keeping the
      # lease alive
      @keep_alive_thread = Thread.new do
        # Immediately send a keep alive request
        keep_alive!

        while state == :OPEN
          sleep @refresh_interval
          keep_alive!
        end
      end
    end

    def lease_id
      @lock.synchronize do
        @lease_id
      end
    end

    def state
      @lock.synchronize do
        @state
      end
    end

    def revoke
      @lock.synchronize do
        on_revoke
      end
    end

    def orphan
      @lock.synchronize do
        on_orphan
      end
    end

    private

    def keep_alive!
      @lock.synchronize do
        if state == :OPEN
          # Push a keep alive request to the stream

          request = Etcdserverpb::LeaseKeepAliveRequest.new ID: @lease_id
          @q.push request
        end
      end
    end

    def on_orphan
      @lock.synchronize do
        @q.cancel
        @state = :ORPHANED
        @listener.on_orphan(self) if @listener
      end
    end

    def on_open
      @lock.synchronize do
        @listener.on_open(self) if @listener
      end
    end

    def on_error(error)
      @lock.synchronize do
        @q.error(error)
        @state = :ERROR
        @listener.on_error(self, error) if @listener
      end
    end

    def on_revoke
      @lock.synchronize do
        # Can only close a currently open session
        if state == :OPEN
          # Let the keep alive connection know we are done
          @q.cancel
          @conn.lease_revoke(@lease_id)
          @state = :REVOKED
          @listener.on_revoke(self) if @listener
        end
      end
    end
  end
end
