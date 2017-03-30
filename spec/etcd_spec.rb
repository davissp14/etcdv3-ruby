require 'spec_helper'

describe Etcd do

  context 'Insecure connection without Auth' do

    let(:conn){ Etcd.new(
      url: 'http://127.0.0.1:2379'
    )}

    describe '#initialize' do

      it 'assigns scheme' do
        expect(conn.scheme).to eq('http')
      end

      it 'assigns host' do
        expect(conn.hostname).to eq('127.0.0.1')
      end

      it 'assigns port' do
        expect(conn.port).to eq(2379)
      end

      it 'returns nil token' do
        expect(conn.token).to eq(nil)
      end

      it 'assigns proper credentials' do
        expect(conn.credentials).to eq(:this_channel_is_insecure)
      end
    end

    describe "#put" do
      it 'issues put request' do
        expect(conn.put('test', 'test')).to be_an_instance_of(Etcdserverpb::PutResponse)
      end
    end

    describe "#range" do
      it 'returns protobuf' do
        expect(conn.range('test', '')).to be_an_instance_of(Google::Protobuf::RepeatedField)
      end

      it 'returns correct result' do
        expect(conn.range('test', '').first.key).to eq('test')
      end
    end

  end

end
