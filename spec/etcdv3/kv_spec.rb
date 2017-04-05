require 'spec_helper'

describe Etcd::KV do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#put' do
    context 'without lease' do
      subject { conn.put('test', 'test') }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end

    context 'with lease' do
      let(:lease_id) { conn.grant_lease(1)['ID'] }
      subject { conn.put('lease', 'test', lease_id) }
      it { is_expected.to be_an_instance_of(Etcdserverpb::PutResponse) }
    end
  end

  describe '#get' do
    before { conn.put('test', "zoom") }
    subject { conn.get('test') }
    it 'returns correct response' do
      expect(subject).to be_an_instance_of(Google::Protobuf::RepeatedField)
      expect(subject.first.key).to eq('test')
      expect(subject.size).to eq(1)
    end
  end
end
