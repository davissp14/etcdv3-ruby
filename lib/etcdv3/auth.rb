
class Etcdv3
  class Auth

    PERMISSIONS = {
      :read => Authpb::Permission::Type::READ,
      :write => Authpb::Permission::Type::WRITE,
      :readwrite => Authpb::Permission::Type::READWRITE
    }

    def initialize(hostname, credentials, metadata = {})
      @stub = Etcdserverpb::Auth::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def auth_enable
      request = Etcdserverpb::AuthEnableRequest.new
      @stub.auth_enable(request)
    end

    def auth_disable
      request = Etcdserverpb::AuthDisableRequest.new
      @stub.auth_disable(request, metadata: @metadata)
    end

    def role_add(name)
      request = Etcdserverpb::AuthRoleAddRequest.new(name: name)
      @stub.role_add(request, metadata: @metadata)
    end

    def role_get(name)
      request = Etcdserverpb::AuthRoleGetRequest.new(role: name)
      @stub.role_get(request, metadata: @metadata)
    end

    def role_delete(name)
      request = Etcdserverpb::AuthRoleDeleteRequest.new(role: name)
      @stub.role_delete(request, metadata: @metadata)
    end

    def role_grant_permission(name, permission, key, range_end)
      permission = Authpb::Permission.new(
        permType: Etcdv3::Auth::PERMISSIONS[permission], key: key, range_end: range_end
      )
      @stub.role_grant_permission(
        Etcdserverpb::AuthRoleGrantPermissionRequest.new(
          name: name,
          perm: permission
        ),
        metadata: @metadata
      )
    end

    def role_revoke_permission(name, permission, key, range_end)
      @stub.role_revoke_permission(
        Etcdserverpb::AuthRoleRevokePermissionRequest.new(
          role: name,
          key: key,
          range_end: range_end
        ),
        metadata: @metadata
      )
    end

    def role_list
      request = Etcdserverpb::AuthRoleListRequest.new
      @stub.role_list(request, metadata: @metadata)
    end

    def user_list
      request = Etcdserverpb::AuthUserListRequest.new
      @stub.user_list(request, metadata: @metadata)
    end

    def user_add(user, password)
      request = Etcdserverpb::AuthUserAddRequest.new(
        name: user,
        password: password
      )
      @stub.user_add(request, metadata: @metadata)
    end

    def user_delete(user)
      request = Etcdserverpb::AuthUserDeleteRequest.new(name: user)
      @stub.user_delete(request)
    end

    def user_get(user)
      request = Etcdserverpb::AuthUserGetRequest.new(name: user)
      @stub.user_get(request)
    end

    def user_change_password(user, new_password)
      request = Etcdserverpb::AuthUserChangePasswordRequest.new(
        name: user,
        password: new_password
      )
      @stub.user_change_password(request, metadata: @metadata)
    end

    def user_grant_role(user, role)
      request = Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)
      @stub.user_grant_role(request, metadata: @metadata)
    end

    def user_revoke_role(user, role)
      request = Etcdserverpb::AuthUserRevokeRoleRequest.new(name: user, role: role)
      @stub.user_revoke_role(request, metadata: @metadata)
    end

    def generate_token(user, password)
      request = Etcdserverpb::AuthenticateRequest.new(
        name: user,
        password: password
      )
      @stub.authenticate(request).token
    end

  end
end
