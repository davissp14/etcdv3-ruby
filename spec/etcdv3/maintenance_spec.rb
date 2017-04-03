require 'spec_helper'

describe Etcd::Maintenance do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#version' do
    subject { conn.version }
    it { is_expected.to_not be_nil }
  end

  describe '#leader_id' do
    subject { conn.leader_id }
    it { is_expected.to_not be_nil }
  end

  describe '#db_size' do
    subject { conn.db_size }
    it { is_expected.to_not be_nil }
  end

  describe '#alarm_list' do
    before { conn.send(:maintenance).alarms(:activate, conn.leader_id, :NOSPACE) }
    after { conn.deactivate_alarms }
    subject { conn.alarm_list }
    it 'returns an alarm' do
        expect(subject).to be_an_instance_of(Etcdserverpb::AlarmResponse)
        expect(subject.alarms.size).to eq(1)
    end
  end

  describe '#deactivate_alarms' do
    before { conn.send(:maintenance).alarms(:activate, conn.leader_id, :NOSPACE) }
    subject { conn.deactivate_alarms }
    it 'deactivates alarms' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AlarmResponse)
      expect(conn.alarm_list.alarms.size).to eq(0)
    end
  end

end
