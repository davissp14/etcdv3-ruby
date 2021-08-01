module Helpers
  module Connections

    def local_connection_with_auth(user, password)
      Etcdv3.new(endpoints: "http://#{local_url}", user: user, password: password)
    end

    def local_connection(endpoints="http://#{local_url}", allow_reconnect: true)
      Etcdv3.new(endpoints: endpoints, allow_reconnect: allow_reconnect)
    end

    def local_connection_with_timeout(timeout)
      Etcdv3.new(endpoints: "http://#{local_url}", command_timeout: timeout)
    end

    def local_connection_with_namespace(namespace)
      Etcdv3.new(endpoints: "http://#{local_url}", namespace: namespace)
    end

    def local_stub(interface, timeout=nil)
      interface.new(local_url, :this_channel_is_insecure, timeout, {})
    end

    def local_namespace_stub(interface, timeout=nil, namespace)
      interface.new(local_url, :this_channel_is_insecure, timeout, namespace, {})
    end

    def local_url
      "127.0.0.1:#{port}"
    end

    def full_local_url
      "http://#{local_url}"
    end

    def port
      ENV.fetch('ETCD_TEST_PORT', 2379).to_i
    end

  end
end
