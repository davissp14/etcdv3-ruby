require 'spec_helper'

describe Etcdv3::Lease do

  let(:stub) { local_stub(Etcdv3::Lease) }

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
  end

  describe '#lease_ttl' do
    let(:id) { stub.lease_grant(10)['ID'] }
    subject { stub.lease_ttl(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseTimeToLiveResponse) }
  end

end
