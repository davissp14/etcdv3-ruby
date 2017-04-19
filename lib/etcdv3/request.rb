require 'base64'
class Etcdv3
  class Request

    HANDLERS = {
      auth: Etcdv3::Auth,
      kv: Etcdv3::KV,
      maintenance: Etcdv3::Maintenance,
      lease: Etcdv3::Lease,
      watch: Etcdv3::Watch
    }

    attr_reader :user, :password, :token

    def initialize(hostname, credentials)
      @user, @password, @token = nil, nil, nil
      @hostname = hostname
      @credentials = credentials
      @handlers = handler_map
    end

    def handle(stub, method, method_args=[], retries: 1)
      @handlers.fetch(stub).send(method, *method_args)
    rescue GRPC::Unauthenticated => exception
      # Regenerate token in the event it expires.
      if exception.details == 'etcdserver: invalid auth token'
        if retries > 0
          authenticate(@user, @password)
          return handle(stub, method, method_args, retries: retries - 1)
        end
      end
      raise exception
    end

    def authenticate(user, password)
      # Attempt to generate token using user and password.
      @token = handle(:auth, 'generate_token', [user, password])
      @user = user
      @password = password
      @handlers = handler_map(token: @token)
    end

    private

    def handler_map(metadata={})
      Hash[
        HANDLERS.map do |key, klass|
          [key, klass.new(@hostname, @credentials, metadata)]
        end
      ]
    end
  end
end
