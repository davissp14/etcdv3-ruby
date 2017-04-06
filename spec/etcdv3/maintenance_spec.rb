require 'spec_helper'

describe Etcd::Maintenance do

  let(:stub) do
    Etcd::Maintenance.new("127.0.0.1:2379", :this_channel_is_insecure, {})
  end

  describe "#member_status" do
    subject { stub.member_status }
    it { is_expected.to be_an_instance_of(Etcdserverpb::StatusResponse)}
  end

  describe '#alarm_list' do
    let(:leader_id) { stub.member_status.leader }
    subject { stub.alarms(:get, leader_id)}
    it { is_expected.to be_an_instance_of(Etcdserverpb::AlarmResponse) }
  end

  describe '#deactivate_alarms' do
    let(:leader_id) { stub.member_status.leader }
    subject { stub.alarms(:deactivate, leader_id, :NOSPACE) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AlarmResponse) }
  end

end
