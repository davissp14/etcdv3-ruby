
module Etcd
  class Client

    def options
      Marshal.load(Martial.dump(@options))
    end

    def uri
      URI(@options[:url])
    end

    def scheme
      uri.scheme
    end

    def port
      uri.port
    end

    def hostname
      uri.hostname
    end

    def user
      @options[:user]
    end

    def password
      @options[:password]
    end

    def credentials
      @credentials
    end

    def token
      @metadata[:token]
    end

    def initialize(options={})
      @options = options
      @metadata = {}
      case scheme
      when "http"
        @credentials = :this_channel_is_insecure
      when "https"
        # Use default certs for now.
        @credentials = GRPC::Core::ChannelCredentials.new
      else
        raise "Unknown scheme: #{scheme}"
      end
    end

    def connect
      if credentials == :this_channel_is_insecure
        # TODO Validate connection
        true
      else
        auth = Etcd::Auth.new(hostname, port, credentials)
        @metadata[:token] = auth.generate_token(@user, @password)
        true
      end
    rescue GRPC::InvalidArgument => exception
      print exception.to_s
    rescue GRPC::Unavailable => exception
      print exception.inspect
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
