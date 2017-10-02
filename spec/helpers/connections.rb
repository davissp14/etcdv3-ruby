module Helpers
  module Connections

    def local_connection_with_auth(user, password)
      Etcdv3.new(endpoints: "http://#{local_url}", user: user, password: password)
    end

    def local_connection(endpoints="http://#{local_url}")
      Etcdv3.new(endpoints: endpoints)
    end

    def local_stub(interface)
      interface.new(local_url, :this_channel_is_insecure, {})
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
