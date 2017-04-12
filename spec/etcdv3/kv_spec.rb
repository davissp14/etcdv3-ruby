require 'spec_helper'

describe Etcdv3::KV do
  let(:stub) { local_stub(Etcdv3::KV) }
  let(:lease_stub) { local_stub(Etcdv3::Lease) }

  describe '#put' do
    context 'without lease' do
      subject { stub.put('test', 'test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end

    context 'with lease' do
      let(:lease_id) { lease_stub.grant_lease(1)['ID'] }
      subject { stub.put('lease', 'test', lease_id) }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end
  end

  describe '#get' do
    subject { stub.get('test') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::RangeResponse) }
  end

  describe '#del' do
    context 'del without range' do
      subject { stub.del('test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::DeleteRangeResponse) }
    end
    context 'del with range' do
      subject { stub.del('test', 'testtt') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::DeleteRangeResponse) }
    end
  end

end
