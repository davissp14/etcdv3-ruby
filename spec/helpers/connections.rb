module Helpers
  module Connections

    def local_connection_with_auth(user, password)
      Etcdv3.new(url: "http://#{local_url}", user: user, password: password)
    end

    def local_connection
      Etcdv3.new(url: "http://#{local_url}")
    end

    def local_connection_with_tls_server_auth(cacert)
      Etcdv3.new(url: "http://#{local_url}", cacert: cacert)
    end

    def local_connection_with_tls_client_auth(cacert, key, cert)
      Etcdv3.new(url: "http://#{local_url}", cacert: cacert, key: key, cert: cert)
    end

    def local_connection_with_auth_and_tls_server_auth(user, password, cacert)
      Etcdv3.new(url: "http://#{local_url}", user: user, password: password, cacert: cacert)
    end

    def local_connection_with_auth_and_tls_client_auth(user, password, cacert, key, cert)
      Etcdv3.new(url: "http://#{local_url}", user: user, password: password, cacert: cacert, key: key, cert: cert)
    end

    def local_stub(interface)
      interface.new(local_url, :this_channel_is_insecure, {})
    end

    def local_url
      "127.0.0.1:#{port}"
    end

    def port
      ENV.fetch('ETCD_TEST_PORT', 2379).to_i
    end

  end
end
