
class Etcdv3
  class Auth
    include GRPC::Core::TimeConsts

    PERMISSIONS = {
      :read => Authpb::Permission::Type::READ,
      :write => Authpb::Permission::Type::WRITE,
      :readwrite => Authpb::Permission::Type::READWRITE
    }

    def initialize(hostname, credentials, timeout, metadata = {}, grpc_options = {})
      @stub = Etcdserverpb::Auth::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @metadata = metadata
    end

    def auth_enable(timeout: nil)
      request = Etcdserverpb::AuthEnableRequest.new
      @stub.auth_enable(request, deadline: deadline(timeout))
    end

    def auth_disable(timeout: nil)
      request = Etcdserverpb::AuthDisableRequest.new
      @stub.auth_disable(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def role_add(name, timeout: nil)
      request = Etcdserverpb::AuthRoleAddRequest.new(name: name)
      @stub.role_add(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def role_get(name, timeout: nil)
      request = Etcdserverpb::AuthRoleGetRequest.new(role: name)
      @stub.role_get(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def role_delete(name, timeout: nil)
      request = Etcdserverpb::AuthRoleDeleteRequest.new(role: name)
      @stub.role_delete(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def role_grant_permission(name, permission, key, range_end, timeout: nil)
      permission = Authpb::Permission.new(
        permType: Etcdv3::Auth::PERMISSIONS[permission], key: key, range_end: range_end
      )
      @stub.role_grant_permission(
        Etcdserverpb::AuthRoleGrantPermissionRequest.new(
          name: name,
          perm: permission
        ),
        metadata: @metadata,
        deadline: deadline(timeout)
      )
    end

    def role_revoke_permission(name, permission, key, range_end, timeout: nil)
      @stub.role_revoke_permission(
        Etcdserverpb::AuthRoleRevokePermissionRequest.new(
          role: name,
          key: key,
          range_end: range_end
        ),
        metadata: @metadata,
        deadline: deadline(timeout)
      )
    end

    def role_list(timeout: nil)
      request = Etcdserverpb::AuthRoleListRequest.new
      @stub.role_list(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_list(timeout: nil)
      request = Etcdserverpb::AuthUserListRequest.new
      @stub.user_list(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_add(user, password, timeout: nil)
      request = Etcdserverpb::AuthUserAddRequest.new(
        name: user,
        password: password
      )
      @stub.user_add(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_delete(user, timeout: nil)
      request = Etcdserverpb::AuthUserDeleteRequest.new(name: user)
      @stub.user_delete(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_get(user, timeout: nil)
      request = Etcdserverpb::AuthUserGetRequest.new(name: user)
      @stub.user_get(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_change_password(user, new_password, timeout: nil)
      request = Etcdserverpb::AuthUserChangePasswordRequest.new(
        name: user,
        password: new_password
      )
      @stub.user_change_password(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_grant_role(user, role, timeout: nil)
      request = Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)
      @stub.user_grant_role(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def user_revoke_role(user, role, timeout: nil)
      request = Etcdserverpb::AuthUserRevokeRoleRequest.new(name: user, role: role)
      @stub.user_revoke_role(request, metadata: @metadata, deadline: deadline(timeout))
    end

    def generate_token(user, password, timeout: nil)
      request = Etcdserverpb::AuthenticateRequest.new(
        name: user,
        password: password
      )
      @stub.authenticate(request, deadline: deadline(timeout)).token
    end

    private

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
