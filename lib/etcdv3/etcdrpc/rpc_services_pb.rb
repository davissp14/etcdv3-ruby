# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: rpc.proto for package 'etcdserverpb'

require 'grpc'
require_relative 'rpc_pb'

module Etcdserverpb
  module KV
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.KV'

      # Range gets the keys in the range from the key-value store.
      rpc :Range, RangeRequest, RangeResponse
      # Put puts the given key into the key-value store.
      # A put request increments the revision of the key-value store
      # and generates one event in the event history.
      rpc :Put, PutRequest, PutResponse
      # DeleteRange deletes the given range from the key-value store.
      # A delete request increments the revision of the key-value store
      # and generates a delete event in the event history for every deleted key.
      rpc :DeleteRange, DeleteRangeRequest, DeleteRangeResponse
      # Txn processes multiple requests in a single transaction.
      # A txn request increments the revision of the key-value store
      # and generates events with the same revision for every completed request.
      # It is not allowed to modify the same key several times within one txn.
      rpc :Txn, TxnRequest, TxnResponse
      # Compact compacts the event history in the etcd key-value store. The key-value
      # store should be periodically compacted or the event history will continue to grow
      # indefinitely.
      rpc :Compact, CompactionRequest, CompactionResponse
    end

    Stub = Service.rpc_stub_class
  end
  module Watch
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.Watch'

      # Watch watches for events happening or that have happened. Both input and output
      # are streams; the input stream is for creating and canceling watchers and the output
      # stream sends events. One watch RPC can watch on multiple key ranges, streaming events
      # for several watches at once. The entire event history can be watched starting from the
      # last compaction revision.
      rpc :Watch, stream(WatchRequest), stream(WatchResponse)
    end

    Stub = Service.rpc_stub_class
  end
  module Lease
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.Lease'

      # LeaseGrant creates a lease which expires if the server does not receive a keepAlive
      # within a given time to live period. All keys attached to the lease will be expired and
      # deleted if the lease expires. Each expired key generates a delete event in the event history.
      rpc :LeaseGrant, LeaseGrantRequest, LeaseGrantResponse
      # LeaseRevoke revokes a lease. All keys attached to the lease will expire and be deleted.
      rpc :LeaseRevoke, LeaseRevokeRequest, LeaseRevokeResponse
      # LeaseKeepAlive keeps the lease alive by streaming keep alive requests from the client
      # to the server and streaming keep alive responses from the server to the client.
      rpc :LeaseKeepAlive, stream(LeaseKeepAliveRequest), stream(LeaseKeepAliveResponse)
      # LeaseTimeToLive retrieves lease information.
      rpc :LeaseTimeToLive, LeaseTimeToLiveRequest, LeaseTimeToLiveResponse
      # LeaseLeases lists all existing leases.
      rpc :LeaseLeases, LeaseLeasesRequest, LeaseLeasesResponse
    end

    Stub = Service.rpc_stub_class
  end
  module Cluster
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.Cluster'

      # MemberAdd adds a member into the cluster.
      rpc :MemberAdd, MemberAddRequest, MemberAddResponse
      # MemberRemove removes an existing member from the cluster.
      rpc :MemberRemove, MemberRemoveRequest, MemberRemoveResponse
      # MemberUpdate updates the member configuration.
      rpc :MemberUpdate, MemberUpdateRequest, MemberUpdateResponse
      # MemberList lists all the members in the cluster.
      rpc :MemberList, MemberListRequest, MemberListResponse
    end

    Stub = Service.rpc_stub_class
  end
  module Maintenance
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.Maintenance'

      # Alarm activates, deactivates, and queries alarms regarding cluster health.
      rpc :Alarm, AlarmRequest, AlarmResponse
      # Status gets the status of the member.
      rpc :Status, StatusRequest, StatusResponse
      # Defragment defragments a member's backend database to recover storage space.
      rpc :Defragment, DefragmentRequest, DefragmentResponse
      # Hash computes the hash of the KV's backend.
      # This is designed for testing; do not use this in production when there
      # are ongoing transactions.
      rpc :Hash, HashRequest, HashResponse
      # HashKV computes the hash of all MVCC keys up to a given revision.
      rpc :HashKV, HashKVRequest, HashKVResponse
      # Snapshot sends a snapshot of the entire backend from a member over a stream to a client.
      rpc :Snapshot, SnapshotRequest, stream(SnapshotResponse)
      # MoveLeader requests current leader node to transfer its leadership to transferee.
      rpc :MoveLeader, MoveLeaderRequest, MoveLeaderResponse
    end

    Stub = Service.rpc_stub_class
  end
  module Auth
    class Service

      include GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'etcdserverpb.Auth'

      # AuthEnable enables authentication.
      rpc :AuthEnable, AuthEnableRequest, AuthEnableResponse
      # AuthDisable disables authentication.
      rpc :AuthDisable, AuthDisableRequest, AuthDisableResponse
      # Authenticate processes an authenticate request.
      rpc :Authenticate, AuthenticateRequest, AuthenticateResponse
      # UserAdd adds a new user.
      rpc :UserAdd, AuthUserAddRequest, AuthUserAddResponse
      # UserGet gets detailed user information.
      rpc :UserGet, AuthUserGetRequest, AuthUserGetResponse
      # UserList gets a list of all users.
      rpc :UserList, AuthUserListRequest, AuthUserListResponse
      # UserDelete deletes a specified user.
      rpc :UserDelete, AuthUserDeleteRequest, AuthUserDeleteResponse
      # UserChangePassword changes the password of a specified user.
      rpc :UserChangePassword, AuthUserChangePasswordRequest, AuthUserChangePasswordResponse
      # UserGrant grants a role to a specified user.
      rpc :UserGrantRole, AuthUserGrantRoleRequest, AuthUserGrantRoleResponse
      # UserRevokeRole revokes a role of specified user.
      rpc :UserRevokeRole, AuthUserRevokeRoleRequest, AuthUserRevokeRoleResponse
      # RoleAdd adds a new role.
      rpc :RoleAdd, AuthRoleAddRequest, AuthRoleAddResponse
      # RoleGet gets detailed role information.
      rpc :RoleGet, AuthRoleGetRequest, AuthRoleGetResponse
      # RoleList gets lists of all roles.
      rpc :RoleList, AuthRoleListRequest, AuthRoleListResponse
      # RoleDelete deletes a specified role.
      rpc :RoleDelete, AuthRoleDeleteRequest, AuthRoleDeleteResponse
      # RoleGrantPermission grants a permission of a specified key or range to a specified role.
      rpc :RoleGrantPermission, AuthRoleGrantPermissionRequest, AuthRoleGrantPermissionResponse
      # RoleRevokePermission revokes a key or range permission of a specified role.
      rpc :RoleRevokePermission, AuthRoleRevokePermissionRequest, AuthRoleRevokePermissionResponse
    end

    Stub = Service.rpc_stub_class
  end
end
