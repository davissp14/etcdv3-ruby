require 'spec_helper'

describe Etcdv3::Namespace::KV do
  let(:stub) { local_namespace_stub(Etcdv3::Namespace::KV, 1, "/namespace/") }
  let(:stub_no_namespace) { local_stub(Etcdv3::KV, 1) }

  let(:lease_stub) { local_stub(Etcdv3::Lease, 1) }

  it "should timeout transactions" do
    stub = local_namespace_stub(Etcdv3::Namespace::KV, 0, '/namespace/')
    expect { stub.transaction(Proc.new { nil }) }.to raise_error(GRPC::DeadlineExceeded)
  end

  describe '#put' do
    context 'without lease' do
      subject { stub.put('test', 'test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end

    context 'with lease' do
      let(:lease_id) { lease_stub.lease_grant(1)['ID'] }
      subject { stub.put('lease', 'test', lease: lease_id) }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end
  end

  describe '#get' do
    before do 
      stub.put("test", "myvalue")
    end

    context 'namespaced' do 
      subject { stub.get('test') }
      it 'returns the correct value' do 
        subject.kvs.last.key.should eq('test')
      end
    end

    context 'w/o namespace' do 
      subject { stub_no_namespace.get('/namespace/test') }
      it 'returns the correct kv' do 
        subject.kvs.last.key.should eq('/namespace/test')
      end
    end
  end

  describe '#del' do
    context 'del without range' do
      subject { stub.del('test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::DeleteRangeResponse) }
    end
    context 'del with range' do
      subject { stub.del('test', range_end: 'testtt') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::DeleteRangeResponse) }
    end
  end

  describe '#transaction' do
    context 'put' do
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

    context 'del' do
      let!(:block) do
        Proc.new do |txn|
          txn.compare = [ txn.value('txn', :equal, 'value') ]
          txn.success = [ txn.del('txn-one') ]
          txn.failure = [ txn.del('txn-two') ]
        end
      end
      subject { stub.transaction(block) }
      it { is_expected.to be_an_instance_of(Etcdserverpb::TxnResponse) }
    end
  end

  context 'get' do
    let!(:block) do
      Proc.new do |txn|
        txn.compare = [ txn.value('txn', :equal, 'value') ]
        txn.success = [ txn.get('txn-success') ]
        txn.failure = [ txn.get('txn-failure') ]
      end
    end
    subject { stub.transaction(block) }
    it { is_expected.to be_an_instance_of(Etcdserverpb::TxnResponse) }
  end
end
