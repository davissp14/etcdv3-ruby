require 'spec_helper'

describe Etcdv3::Maintenance do

  let(:stub) { local_stub(Etcdv3::Maintenance) }
  test_instance = Helpers::TestInstance.new(tls: false)

  before(:context) do
    test_instance.start
  end

  after(:context) do
    test_instance.stop
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

  describe '#alarm_deactivate' do
    let(:leader_id) { stub.member_status.leader }
    subject { stub.alarms(:deactivate, leader_id, :NOSPACE) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AlarmResponse) }
  end

end
