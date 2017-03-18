
module Etcd
  class AuthService

    def self.client
      @creds ||= GRPC::Core::ChannelCredentials.new(File.read(ENV['CA_FILE']))
      @client ||= Etcdserverpb::Auth::Stub.new(ENV['ENDPOINTS'], creds)
      @client
    end

    def user_list

    end

  end
end
