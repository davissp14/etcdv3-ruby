require 'ostruct'

class Etcd
  class Maintenance
    # Sadly these are the only alarm types supported by the api right now.
    ALARM_TYPES = {
      NONE: 0,
      NOSPACE: 1
    }

    ALARM_ACTIONS = {
      get: 0,
      activate: 1, # Should only be used in testing. Not a stable feature...
      deactivate: 2
    }

    def initialize(hostname, port, credentials, metadata = {})
      @stub = Etcdserverpb::Maintenance::Stub.new("#{hostname}:#{port}", credentials)
      @metadata = metadata
    end

    def member_status
      @stub.status(Etcdserverpb::StatusRequest.new, metadata: @metadata)
    end

    def alarms(action, member_id, alarm=:NONE)
      alarm = ALARM_TYPES[alarm]
      request = Etcdserverpb::AlarmRequest.new(
        action: ALARM_ACTIONS[action],
        memberID: member_id,
        alarm: action == :deactivate ? ALARM_TYPES[:NOSPACE] : alarm
      )
      @stub.alarm(request)
    end
  end
end
