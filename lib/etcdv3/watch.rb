class Etcdv3
  class Watch

    def initialize(hostname, credentials, metadata = {})
      @stub = Etcdserverpb::Watch::Stub.new(hostname, credentials)
      @metadata = metadata
    end

    def watch(key, range_end, block)
      create_req = Etcdserverpb::WatchCreateRequest.new(key: key, range_end: range_end)
      watch_req = Etcdserverpb::WatchRequest.new(create_request: create_req)
      events = nil
      @stub.watch([watch_req], metadata: @metadata).each do |resp|
        next if resp.events.empty?
        if block
          block.call(resp.events)
        else
          events = resp.events
          break
        end
      end
      events
    end
  end
end
