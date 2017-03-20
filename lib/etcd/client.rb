module Etcd
  class Client
    def initialize(hostname="127.0.0.1:2379", certs=:this_channel_is_insecure)
      @hostname = hostname
      @certs = certs
      @metadata = {}
      @conn ||= Etcdserverpb::KV::Stub.new("#{hostname}", certs)
    end

    def authenticate(user, password)
      auth = Etcdserverpb::Auth::Stub.new(@hostname, @certs)
      result = auth.authenticate(Authpb::User.new(name: user, password: password))
      @metadata = {token: result.token}
    rescue GRPC::InvalidArgument => exception
      print exception.to_s
    end

    def put(key, value)
      stub = Etcdserverpb::PutRequest.new(key: key, value: value)
      @conn.put(stub, metadata: @metadata)
    end

    def range(key, range_end="")
      stub = Etcdserverpb::RangeRequest.new(key: key, range_end: range_end)
      result = @conn.range(stub, metadata: @metadata)
      result.kvs
    end

  end
end
