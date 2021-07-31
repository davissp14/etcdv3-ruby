class Etcdv3::Namespace
  module Util
    
    def prepend_prefix(prefix, key)
      key.prepend(prefix)
    end

    def strip_prefix(prefix, resp)
      [:kvs, :prev_kvs].each do |field|
        if resp.respond_to?(field)
          resp.send(field).each do |kv| 
            kv.key = kv.key.delete_prefix(prefix)
          end
        end
      end
      resp
    end

    def strip_prefix_from_events(prefix, events)
      events.each do |event|
        if event.kv
          event.kv.key = event.kv.key.delete_prefix(prefix) 
        end
        if event.prev_kv
          event.prev_kv.key = event.prev_kv.key.delete_prefix(prefix) 
        end
      end
    end

  end
end