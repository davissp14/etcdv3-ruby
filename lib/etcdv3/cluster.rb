class Etcdv3
  class Cluster
    def initialize(hostname, credentials, metadata = {})
      @stub = Etcdserverpb::Cluster::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def member_list
      request = Etcdserverpb::MemberListRequest.new
      @stub.member_list(request)
    end

  end
end
