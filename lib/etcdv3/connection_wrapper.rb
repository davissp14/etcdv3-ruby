class Etcdv3
  class ConnectionWrapper

    attr_accessor :connection, :endpoints, :user, :password, :token, :timeout

    def initialize(timeout, *endpoints)
      @user, @password, @token = nil, nil, nil
      @timeout = timeout
      @endpoints = endpoints.map{|endpoint| Etcdv3::Connection.new(endpoint, @timeout) }
      @connection = @endpoints.first
    end

    def handle(stub, method, method_args=[])
      @connection.call(stub, method, method_args)

    rescue GRPC::Unavailable, GRPC::Core::CallError
      $stderr.puts("Failed to connect to endpoint '#{@connection.hostname}'")
      if @endpoints.size > 1
        rotate_connection_endpoint
        $stderr.puts("Failover event triggered. Failing over to '#{@connection.hostname}'")
      end
      raise
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
