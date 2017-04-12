require 'spec_helper'

describe Etcdv3::Lease do

  let(:stub) { local_stub(Etcdv3::Lease) }

  describe '#grant_lease' do
    subject { stub.grant_lease(10) }
    it 'grants lease' do
      expect(subject).to be_an_instance_of(Etcdserverpb::LeaseGrantResponse)
      expect(subject['ID']).to_not be_nil
    end
  end

  describe '#revoke_lease' do
    let(:id) { stub.grant_lease(60)['ID'] }
    subject { stub.revoke_lease(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseRevokeResponse) }
  end

  describe '#lease_ttl' do
    let(:id) { stub.grant_lease(10)['ID'] }
    subject { stub.lease_ttl(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseTimeToLiveResponse) }
  end

end
