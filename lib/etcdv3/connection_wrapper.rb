class Etcdv3
  class ConnectionWrapper

    attr_accessor :connection, :endpoints, :user, :password, :token, :timeout

    def initialize(timeout, *endpoints, allow_reconnect:)
      @user, @password, @token = nil, nil, nil
      @timeout = timeout
      @endpoints = endpoints.map{|endpoint| Etcdv3::Connection.new(endpoint, @timeout) }
      @connection = @endpoints.first
      @allow_reconnect = allow_reconnect
    end

    private def retry_or_raise(*args)
      if @allow_reconnect
        handle(*args)
      else
        raise
      end
    end

    def handle(stub, method, method_args=[], retries: 1)
      @connection.call(stub, method, method_args)

    rescue GRPC::Unavailable, GRPC::Core::CallError
      $stderr.puts("Failed to connect to endpoint '#{@connection.hostname}'")
      if @endpoints.size > 1
        rotate_connection_endpoint
        $stderr.puts("Failover event triggered. Failing over to '#{@connection.hostname}'")
        return retry_or_raise(stub, method, method_args)
      else
        return retry_or_raise(stub, method, method_args)
      end
    rescue GRPC::Unauthenticated => exception
      # Regenerate token in the event it expires.
      if exception.details == 'etcdserver: invalid auth token'
        if retries > 0
          authenticate(@user, @password)
          return retry_or_raise(stub, method, method_args, retries: retries - 1)
        end
      end
      raise exception
    end

    def clear_authentication
      @user, @password, @token = nil, nil, nil
      @connection.refresh_metadata({})
    end

    # Authenticate using specified user and password..
    def authenticate(user, password)
      @token = handle(:auth, 'generate_token', [user, password])
      @user, @password = user, password
      @connection.refresh_metadata(token: @token)
    end

    # Simple failover mechanism that rotates the connection endpoints in an
    # attempt to recover connectivity.
    def rotate_connection_endpoint
      @endpoints.rotate!
      @connection = @endpoints.first
      @connection.refresh_metadata(token: @token) if @token
    end
  end
end
