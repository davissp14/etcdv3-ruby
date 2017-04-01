
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
      response = @stub.authenticate(
        Authpb::User.new(name: user, password: password)
      )
      response.token
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
      false
    end

    def user_list
      @stub.user_list(Authpb::User.new, metadata: @metadata).users
    end

    def add_user(user, password)
      @stub.user_add(
        Authpb::User.new(name: user, password: password), metadata: @metadata
      )
    end

    def delete_user(user)
      @stub.user_delete(Authpb::User.new(name: user))
    end

    def get_user(user)
      @stub.user_get(Authpb::User.new(name: user))
    end

    def change_user_password(user, new_password)
      request = Etcdserverpb::AuthUserChangePasswordRequest.new(
        name: user,
        password: new_password
      )
      @stub.user_change_password(request, metadata: @metadata)
    end

    def add_role(name, permission, key, range_end)
      permission = Authpb::Permission.new(
        permType: Etcd::Auth::PERMISSIONS[permission], key: key, range_end: range_end
      )
      @stub.role_add(
        Authpb::Role.new(name: name, keyPermission: [permission]),
        metadata: @metadata
      )
    end

    def get_role(name)
      request = Etcdserverpb::AuthRoleGetRequest.new(role: name)
      @stub.role_get(request, metadata: @metadata)
    end

    def delete_role(name)
      @stub.role_delete(Authpb::Role.new(name: name), metadata: @metadata)
    end

    def grant_role_to_user(user, role)
      request = Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)
      @stub.user_grant_role(request, metadata: @metadata)
    end

    def revoke_role_from_user(user, role)
      request = Etcdserverpb::AuthUserRevokeRoleRequest.new(name: user, role: role)
      @stub.user_revoke_role(request, metadata: @metadata)
    end

    def role_list
      @stub.role_list(Authpb::Role.new, metadata: @metadata)
    end

    def enable_auth
      @stub.auth_enable(Authpb::User.new)
    end

    def disable_auth
      @stub.auth_disable(Authpb::User.new, metadata: @metadata)
    end

  end
end
