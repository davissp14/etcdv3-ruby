require 'spec_helper'

describe Etcd::Client do

  describe '#initialize' do

    context 'insecure connection with auth' do

      let(:client){ Etcd.new(
        url: 'http://127.0.0.1:2379',
        user: "root",
        password: "ginger"
      )}

      it 'assigns scheme' do
        expect(client.scheme).to eq('http')
      end

      it 'assigns host' do
        expect(client.hostname).to eq('127.0.0.1')
      end

      it 'assigns port' do
        expect(client.port).to eq(2379)
      end

      it 'assigns user' do
        expect(client.user).to eq('root')
      end

      it 'assigns password' do
        expect(client.password).to eq('ginger')
      end

      it 'resolves token' do
        expect(client.token).to_not be_nil
      end

      it 'assigns proper credentials' do
        expect(client.credentials).to eq(:this_channel_is_insecure)
      end

      it 'issues put request' do
        expect(client.put('test', 'test')).to be_an_instance_of(Etcdserverpb::PutResponse)
      end

      it 'issues range request' do
        expect(client.range('test', '')).to be_an_instance_of(Google::Protobuf::RepeatedField)
        expect(client.range('test', '').first.key).to eq('test')
      end

    end

    # context 'secure connection using default certificates' do
    #   let(:client){ Etcd.new(
    #     url: 'https://127.0.0.1:2379',
    #     user: "root",
    #     password: "ginger"
    #   )}
    #
    #   it 'assigns scheme' do
    #     expect(client.scheme).to eq('https')
    #   end
    #
    #   it 'assigns host' do
    #     expect(client.hostname).to eq('127.0.0.1')
    #   end
    #
    #   it 'assigns port' do
    #     expect(client.port).to eq(2379)
    #   end
    #
    #   it 'assigns proper credentials' do
    #     expect(client.credentials).to be_an_instance_of(GRPC::Core::ChannelCredentials)
    #   end
    # end
  end
end
