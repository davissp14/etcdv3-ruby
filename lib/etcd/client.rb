module Etcd
  class Client

    def initialize(hostname="127.0.0.1:2379", certs=:this_channel_is_insecure, servername_override=nil)
      @hostname = hostname
      case certs
      when :this_channel_is_insecure
        @certs = :this_channel_is_insecure
      when :ssl_no_certs
        @certs = GRPC::Core::ChannelCredentials.new
      else
        raise("Cert type not available yet.")
      end
      @channel_args = {}
      @channel_args[GRPC::Core::Channel::SSL_TARGET] = servername_override if servername_override
      @metadata = {}
      @conn ||= Etcdserverpb::KV::Stub.new("#{hostname}", @certs, channel_args: @channel_args)
    end

    def authenticate(user, password)
      auth = Etcdserverpb::Auth::Stub.new(@hostname, @certs, channel_args: @channel_args)
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
