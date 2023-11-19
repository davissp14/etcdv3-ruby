class Etcdv3::Namespace
  class Watch
    include GRPC::Core::TimeConsts
    include Etcdv3::Namespace::Utilities

    def initialize(hostname, credentials, timeout, namespace, metadata = {}, grpc_options = {})
      @stub = Etcdserverpb::Watch::Stub.new(hostname, credentials, **grpc_options)
      @timeout = timeout
      @namespace = namespace
      @metadata = metadata
    end

    def watch(key, range_end, start_revision, block, timeout: nil)      
      key = prepend_prefix(@namespace, key)
      range_end = prepend_prefix(@namespace, range_end) if range_end
      create_req = Etcdserverpb::WatchCreateRequest.new(key: key)
      create_req.range_end = range_end if range_end
      create_req.start_revision = start_revision if start_revision
      watch_req = Etcdserverpb::WatchRequest.new(create_request: create_req)
      events = nil
      @stub.watch([watch_req], metadata: @metadata, deadline: deadline(timeout)).each do |resp|
        next if resp.events.empty?
        if block
          block.call(strip_prefix_from_events(@namespace, resp.events))
        else
          events = strip_prefix_from_events(@namespace, resp.events)
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
