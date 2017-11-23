module Helpers
  module Connections

    def local_url
      "127.0.0.1:#{port}"
    end

    # Includes Scheme
    def full_local_url
      "http://127.0.0.1:#{port}"
    end

    def local_connection(endpoints = full_local_url)
      Etcdv3.new(endpoints: endpoints)
    end

    def local_connection_with_auth(user, password)
      Etcdv3.new(
        endpoints: full_local_url,
        user: user,
        password: password
      )
    end

    def local_connection_with_timeout(timeout = 5)
      Etcdv3.new(
        endpoints: full_local_url,
        command_timeout: timeout
      )
    end

    def local_stub(interface, timeout = nil)
      interface.new(local_url, :this_channel_is_insecure, timeout, {})
    end

    def port
      ENV.fetch('ETCD_TEST_PORT', 2379).to_i
    end
  end
end
