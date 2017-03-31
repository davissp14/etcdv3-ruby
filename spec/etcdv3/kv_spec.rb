require 'spec_helper'

describe Etcd::KV do

  let(:stub) do
    Etcd::KV.new('127.0.0.1', 2379, :this_channel_is_insecure)
  end

  describe '#put' do
    it 'returns PutResponse' do
      expect(stub.put('test', 'test')).to \
        be_an_instance_of(Etcdserverpb::PutResponse)
    end
  end

  describe '#range' do
    before do
      stub.put('test', "zoom")
    end
    it 'returns protobuf' do
      expect(stub.range('test', '')).to \
        be_an_instance_of(Google::Protobuf::RepeatedField)
    end

    it 'returns correct result' do
      expect(stub.range('test', '').first.key).to eq('test')
    end
  end


end
