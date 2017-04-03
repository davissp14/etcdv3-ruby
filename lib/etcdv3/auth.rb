class Etcd
  module Auth
    STUB = Etcdserverpb::Auth::Stub

    PERMISSIONS = {
      'read' => Authpb::Permission::Type::READ,
      'write' => Authpb::Permission::Type::WRITE,
      'readwrite' => Authpb::Permission::Type::READWRITE
    }

    def generate_token(user, password)
      resolve_request('AuthenticateRequest','authenticate',
        attributes: {
          name: user,
          password: password
        }
      ).token
    end

    def user_list
      resolve_request('AuthUserListRequest','user_list')
    end

    def add_user(user, password)
      resolve_request('AuthUserAddRequest','user_add',
        attributes: {
          name: user,
          password: password
        }
      )
    end

    def delete_user(user)
      resolve_request('AuthUserDeleteRequest','user_delete',
        attributes: {
          name: user
        }
      )
    end

    def get_user(user)
      resolve_request('AuthUserGetRequest','user_get',
        attributes: {
          name: user
        }
      )
    end

    def change_user_password(user, new_password)
      resolve_request('AuthUserChangePasswordRequest','user_change_password',
        attributes: {
          name: user,
          password: new_password
        }
      )
    end

    def add_role(role)
      resolve_request('AuthRoleAddRequest', 'role_add',
        attributes: {
          name: role
        }
      )
    end

    def get_role(role)
      resolve_request('AuthRoleGetRequest', 'role_get',
        attributes: {
          role: role
        }
      )
    end

    def delete_role(role)
      resolve_request('AuthRoleDeleteRequest','role_delete',
        attributes: {
          role: role
        }
      )
    end

    def grant_role_to_user(user, role)
      resolve_request('AuthUserGrantRoleRequest','user_grant_role',
        attributes: {
          user: user,
          role: role
        }
      )
    end

    def revoke_role_from_user(user, role)
      resolve_request('AuthUserRevokeRoleRequest','user_revoke_role',
        attributes: {
          name: user,
          role: role
        }
      )
    end

    def grant_permission_to_role(name, permission, key, range_end)
      permission = Authpb::Permission.new(
        permType: PERMISSIONS[permission],
        key: key,
        range_end: range_end
      )
      resolve_request('AuthRoleGrantPermissionRequest','role_grant_permission',
        attributes: {
          name: name,
          perm: permission
        }
      )
    end

    def revoke_permission_from_role(name, permission, key, range_end)
      resolve_request('AuthRoleRevokePermissionRequest','role_revoke_permission',
        attributes: {
          role: name,
          key: key,
          range_end: range_end
        }
      )
    end

    def role_list
      resolve_request('AuthRoleListRequest', 'role_list')
    end

    def enable_auth
      resolve_request('AuthEnableRequest', 'auth_enable', auth: false)
    end

    def disable_auth
      resolve_request('AuthDisableRequest', 'auth_disable')
    end

  end
end
