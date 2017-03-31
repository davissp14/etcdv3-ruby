
class Etcd
  class Auth

    PERMISSIONS = {
      'read' => Authpb::Permission::Type::READ,
      'write' => Authpb::Permission::Type::WRITE,
      'readwrite' => Authpb::Permission::Type::READWRITE
    }

    def initialize(hostname, port, credentials)
      @stub = Etcdserverpb::Auth::Stub.new("#{hostname}:#{port}", credentials)
    end

    def generate_token(user, password)
      response = @stub.authenticate(
        Authpb::User.new(name: user, password: password)
      )
      response.token
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def user_list(metadata = {})
      @stub.user_list(Authpb::User.new, metadata: metadata).users
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def add_user(user, password, metadata = {})
      @stub.user_add(
        Authpb::User.new(name: user, password: password), metadata: metadata
      )
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def delete_user(user, metadata = {})
      @stub.user_delete(Authpb::User.new(name: user), metadata: metadata)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def add_role(name, permission, key, range_end, metadata = {})
      permission = Authpb::Permission.new(
        permType: Etcd::Auth::PERMISSIONS[permission], key: key, range_end: range_end
      )
      @stub.role_add(
        Authpb::Role.new(name: name, keyPermission: [permission]),
        metadata: metadata
      )
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def delete_role(name, metadata = {})
      @stub.role_delete(Authpb::Role.new(name: name), metadata: metadata)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def grant_role_to_user(user, role, metadata = {})
      request = Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)
      @stub.user_grant_role(request)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def role_list(metadata = {})
      @stub.role_list(Authpb::Role.new, metadata: metadata)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def enable_auth
      @stub.auth_enable(Authpb::User.new)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

    def disable_auth(metadata = {})
      @stub.auth_disable(Authpb::User.new, metadata: metadata)
    rescue GRPC::FailedPrecondition => exception
      puts exception.message
    end

  end
end
