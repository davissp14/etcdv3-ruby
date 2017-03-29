
class Etcd
  class Auth

    def initialize(hostname, port, certs)
      @stub = Etcdserverpb::Auth::Stub.new("#{hostname}:#{port}", certs)
    end

    def generate_token(user, password)
      response = @stub.authenticate(Authpb::User.new(name: user, password: password))
      response.token
    end

  end
end
