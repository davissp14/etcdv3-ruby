
class Etcd
  module Maintenance
    STUB = Etcdserverpb::Maintenance::Stub

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

    def member_status
      resolve_request('StatusRequest', 'status')
    end

    def alarms(action, member_id, alarm=:NONE)
      resolve_request('AlarmRequest', 'alarm',
        attributes: {
          action: ALARM_ACTIONS[action],
          memberID: member_id,
          alarm: action == :deactivate ? ALARM_TYPES[:NOSPACE] : ALARM_TYPES[alarm]
        }
      )
    end
  end
end
