require 'spec_helper'

describe Etcdv3::Lease do

  let(:stub) { local_stub(Etcdv3::Lease, 5) }

  it_should_behave_like "a method with a GRPC timeout", described_class, :lease_grant, :lease_grant, 10
  describe '#lease_grant' do
    subject { stub.lease_grant(10) }
    it 'grants lease' do
      expect(subject).to be_an_instance_of(Etcdserverpb::LeaseGrantResponse)
      expect(subject['ID']).to_not be_nil
    end
  end

  describe '#lease_revoke' do
    let(:id) { stub.lease_grant(60)['ID'] }
    subject { stub.lease_revoke(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseRevokeResponse) }

    it 'raises a GRPC:DeadlineExceeded if the request takes too long' do
      stub = local_stub(Etcdv3::Lease, 0)
      expect { stub.lease_revoke(id) }.to raise_error(GRPC::DeadlineExceeded)
    end
  end

  describe '#lease_keep_alive_once' do
    let(:id) { stub.lease_grant(60)['ID'] }
    subject { stub.lease_keep_alive_once(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseKeepAliveResponse) }
    it 'raises a GRPC:DeadlineExceeded if the request takes too long' do
      stub = local_stub(Etcdv3::Lease, 0)
      expect { stub.lease_keep_alive_once(id) }.to raise_error(GRPC::DeadlineExceeded)
    end
    it "doesn't orphan threads if there is a server error" do
      expect_any_instance_of(GRPC::BidiCall).to receive(:read_loop).and_raise(GRPC::DeadlineExceeded)
      stub = local_stub(Etcdv3::Lease, 2)
      expect { stub.lease_keep_alive_once(314159) rescue nil; sleep 0.5}.to_not change { Thread.list.size }
    end
  end

  describe '#lease_ttl' do
    let(:stub) { local_stub(Etcdv3::Lease, 1) }
    let(:lease_id) { stub.lease_grant(10)['ID'] }
    subject { stub.lease_ttl(lease_id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseTimeToLiveResponse) }

    it 'raises a GRPC:DeadlineExceeded if the request takes too long' do
      stub = local_stub(Etcdv3::Lease, 0)
      expect { stub.lease_ttl(lease_id) }.to raise_error(GRPC::DeadlineExceeded)
    end
  end
end
