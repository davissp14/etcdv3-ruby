
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
  class Session
    def initialize(conn,
                   keep_alive_interval: 10,
                   lease_ttl: 15,
                   listener: nil)
      # The etcd3 connection to associate the session with
      @conn = conn

      # Monitor used to synchronize access to the session
      # we use a Monitor instead of Mutex for reentrancy
      @lock = Monitor.new

      # How often we send a keep alive request
      @keep_alive_interval = keep_alive_interval

      # Session listener that can receive messages
      # like:
      #   1. on_open - called when the session opens
      #   2. on_error - called when the session errors for some reason
      #   3. on_close - called when the session is closed by user
      @listener = listener

      # The Time To Live for the lease
      @lease_ttl = lease_ttl

      # Create the lease that we will keep open for the
      # duration of the session
      @lease = @conn.lease_grant(@lease_ttl)

      # Use this queue object to push keep
      # alive requests to the server
      @q = EnumeratorQueue.new(self)

      # Get the enumerable that comes back
      # with all of the responses from the
      # etcd3 server
      @responses = @conn.lease_keep_alive(@q)

      # We are in the OPEN state until
      # until we close the session or
      # receive an error
      @state = :OPEN

      # Call on_open of the listener if passed in
      on_open
      @listener.on_open(self) if @listener

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
      end

      # This thread is responsible for keeping the
      # lease alive
      @keep_alive_thread = Thread.new do
        sleep @refresh_interval
        @q.push @lease.ID
      end
    end

    def close
      @lock.synchronize
    end

    private

    def on_open
      @lock.synchronize do
        @listener.on_open(self) if @listener
      end
    end

    def on_error(error)
      @lock.synchronize do
        @listener.on_error(self, error) if @listener

        @q.push(error)

        @keep_alive_thread.join
        @response_thread.join

        @state = :ERROR
      end
    end

    def on_close
      @lock.synchronize do
        # Can only close a currently open session
        if state == :OPEN
          @listener.on_close(self) if @listener

          # Let the keep alive connection know we are done
          @q.push(self)

          @keep_alive_thread.join
          @response_thread.join

          @state = :CLOSED
        end
      end
    end
  end
end
