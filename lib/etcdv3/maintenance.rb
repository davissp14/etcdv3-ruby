require 'ostruct'

class Etcd
  class Maintenance
    def initialize(hostname, port, credentials, metadata = {})
      @stub = Etcdserverpb::Maintenance::Stub.new("#{hostname}:#{port}", credentials)
      @metadata = metadata
    end

    def member_status
      @stub.status(Etcdserverpb::StatusRequest.new, metadata: @metadata)
    end
  end
end
