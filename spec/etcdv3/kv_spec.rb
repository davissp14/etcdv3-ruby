require 'spec_helper'

describe Etcd::KV do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#put' do
    it 'returns PutResponse' do
      expect(conn.put('test', 'test')).to \
        be_an_instance_of(Etcdserverpb::PutResponse)
    end
  end

  describe '#get' do
    before do
      conn.put('test', "zoom")
    end
    it 'returns protobuf' do
      expect(conn.get('test')).to \
        be_an_instance_of(Google::Protobuf::RepeatedField)
    end

    it 'returns correct result' do
      expect(conn.get('test').first.key).to eq('test')
    end
  end
end
