
class Etcd
  class Auth

    def initialize(hostname, port, credentials)
      @stub = Etcdserverpb::Auth::Stub.new("#{hostname}:#{port}", credentials)
    end

    def generate_token(user, password)
      response = @stub.authenticate(Authpb::User.new(name: user, password: password))
      response.token
    end

    def user_list(metadata={})
      @stub.user_list(Authpb::User.new, metadata: metadata).users
    end

    def add_user(user, password, metadata={})
      @stub.user_add(Authpb::User.new(name: user, password: password), metadata: metadata)

    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def delete_user(user, metadata={})
      @stub.user_delete(Authpb::User.new(name: user), metadata: metadata)

    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

  end
end
