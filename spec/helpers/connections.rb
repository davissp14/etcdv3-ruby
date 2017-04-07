module Helpers
  module Connections

    def local_connection
      Etcd.new(url: "http://#{local_url}")
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
