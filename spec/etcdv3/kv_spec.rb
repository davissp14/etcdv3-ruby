require 'spec_helper'

describe Etcdv3::KV do
  let(:stub) { local_stub(Etcdv3::KV, 1) }
  let(:lease_stub) { local_stub(Etcdv3::Lease, 1) }

  it_should_behave_like "a method with a GRPC timeout", described_class, :get, :range, "key"
  it_should_behave_like "a method with a GRPC timeout", described_class, :del, :delete_range, "key"
  it_should_behave_like "a method with a GRPC timeout", described_class, :put, :put, "key", "val"

  it "should timeout transactions" do
    stub = local_stub(Etcdv3::KV, 0)
    expect { stub.transaction(Proc.new { nil }) }.to raise_error(GRPC::DeadlineExceeded)
  end

  describe '#put' do
    context 'without lease' do
      subject { stub.put('test', 'test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end

    context 'with lease' do
      let(:lease_id) { lease_stub.lease_grant(1)['ID'] }
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

  describe '#transaction' do
    let!(:block) do
      Proc.new do |txn|
        txn.compare = [ txn.value('txn', :equal, 'value') ]
        txn.success = [ txn.put('txn-test', 'success') ]
        txn.failure = [ txn.put('txn-test', 'failed') ]
      end
    end
    subject { stub.transaction(block) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::TxnResponse) }
  end
end
