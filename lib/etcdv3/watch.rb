class Etcdv3
  class Watch
    include GRPC::Core::TimeConsts

    def initialize(hostname, credentials, timeout, metadata = {})
      @stub = Etcdserverpb::Watch::Stub.new(hostname, credentials)
      @timeout = timeout
      @metadata = metadata
    end

    def watch(key, range_end, start_revision, block, timeout: nil)
      create_req = Etcdserverpb::WatchCreateRequest.new(key: key)
      create_req.range_end = range_end if range_end
      create_req.start_revision = start_revision if start_revision
      watch_req = Etcdserverpb::WatchRequest.new(create_request: create_req)
      events = nil
      @stub.watch([watch_req], metadata: @metadata, deadline: deadline(timeout)).each do |resp|
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

    def deadline(timeout)
      from_relative_time(timeout || @timeout)
    end
  end
end
