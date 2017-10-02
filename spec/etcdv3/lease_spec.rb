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
