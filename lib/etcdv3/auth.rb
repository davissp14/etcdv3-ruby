
class Etcd
  class Auth

    PERMISSIONS = {
      'read' => Authpb::Permission::Type::READ,
      'write' => Authpb::Permission::Type::WRITE,
      'readwrite' => Authpb::Permission::Type::READWRITE
    }

    def initialize(hostname, port, credentials, metadata = {})
      @stub = Etcdserverpb::Auth::Stub.new("#{hostname}:#{port}", credentials)
      @metadata = metadata
    end

    def generate_token(user, password)
      request = Etcdserverpb::AuthenticateRequest.new(
        name: user,
        password: password
      )
      @stub.authenticate(request).token
    end

    def user_list
      request = Etcdserverpb::AuthUserListRequest.new
      @stub.user_list(request, metadata: @metadata).users
    end

    def add_user(user, password)
      request = Etcdserverpb::AuthUserAddRequest.new(
        name: user,
        password: password
      )
      @stub.user_add(request, metadata: @metadata)
    end

    def delete_user(user)
      request = Etcdserverpb::AuthUserDeleteRequest.new(name: user)
      @stub.user_delete(request)
    end

    def get_user(user)
      request = Etcdserverpb::AuthUserGetRequest.new(name: user)
      @stub.user_get(request)
    end

    def change_user_password(user, new_password)
      request = Etcdserverpb::AuthUserChangePasswordRequest.new(
        name: user,
        password: new_password
      )
      @stub.user_change_password(request, metadata: @metadata)
    end

    def add_role(name)
      request = Etcdserverpb::AuthRoleAddRequest.new(name: name)
      @stub.role_add(request, metadata: @metadata)
    end

    def get_role(name)
      request = Etcdserverpb::AuthRoleGetRequest.new(role: name)
      @stub.role_get(request, metadata: @metadata)
    end

    def delete_role(name)
      request = Etcdserverpb::AuthRoleDeleteRequest.new(role: name)
      @stub.role_delete(request, metadata: @metadata)
    end

    def grant_role_to_user(user, role)
      request = Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)
      @stub.user_grant_role(request, metadata: @metadata)
    end

    def revoke_role_from_user(user, role)
      request = Etcdserverpb::AuthUserRevokeRoleRequest.new(name: user, role: role)
      @stub.user_revoke_role(request, metadata: @metadata)
    end

    def grant_permission_to_role(name, permission, key, range_end)
      permission = Authpb::Permission.new(
        permType: Etcd::Auth::PERMISSIONS[permission], key: key, range_end: range_end
      )
      @stub.role_grant_permission(
        Etcdserverpb::AuthRoleGrantPermissionRequest.new(
          name: name,
          perm: permission
        ),
        metadata: @metadata
      )
    end

    def revoke_permission_from_role(name, permission, key, range_end)
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

    def enable_auth
      request = Etcdserverpb::AuthEnableRequest.new
      @stub.auth_enable(request)
    end

    def disable_auth
      request = Etcdserverpb::AuthDisableRequest.new
      @stub.auth_disable(request, metadata: @metadata)
    end

  end
end
