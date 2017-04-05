require 'spec_helper'

describe Etcd::Lease do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#grant_lease' do
    subject { conn.grant_lease(10) }
    it 'grants lease' do
      expect(subject).to be_an_instance_of(Etcdserverpb::LeaseGrantResponse)
      expect(subject['ID']).to_not be_nil
    end
  end

  describe '#revoke_lease' do
    let(:id) { conn.grant_lease(60)['ID'] }
    subject { conn.revoke_lease(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseRevokeResponse) }
  end

  describe '#lease_ttl' do
    let(:id) { conn.grant_lease(10)['ID'] }
    subject { conn.lease_ttl(id) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::LeaseTimeToLiveResponse) }
  end

end
