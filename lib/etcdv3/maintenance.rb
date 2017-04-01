require 'ostruct'
class Etcd
  class Maintenance
    def initialize(hostname, port, credentials, metadata = {})
      @stub = Etcdserverpb::Maintenance::Stub.new("#{hostname}:#{port}", credentials)
      @metadata = metadata
    end

    def member_status
      resp = @stub.status(Etcdserverpb::StatusRequest.new, metadata: @metadata)
      OpenStruct.new(
        version: resp.version,
        db_size: resp.dbSize,
        cluster_id: resp.header.cluster_id,
        member_id: resp.header.member_id,
        leader_id: resp.leader,
        raft_index: resp.raftIndex,
        raft_term: resp.raftTerm
      )
    end
  end
end
