require 'spec_helper'

describe Etcd::Client do

  describe '#initialize' do

    context 'insecure connection with auth' do

      let(:client){ Etcd::Client.new(
        url: 'http://127.0.0.1:2379',
        user: "test",
        password: "password"
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
        expect(client.user).to eq('test')
      end

      it 'assigns password' do
        expect(client.password).to eq('password')
      end

      it 'assigns proper credentials' do
        expect(client.credentials).to eq(:this_channel_is_insecure)
      end

    end

    context 'secure connection using default certificates' do
      let(:client){ Etcd::Client.new(url: 'https://127.0.0.1:2379') }

      it 'assigns scheme' do
        expect(client.scheme).to eq('https')
      end

      it 'assigns host' do
        expect(client.hostname).to eq('127.0.0.1')
      end

      it 'assigns port' do
        expect(client.port).to eq(2379)
      end

      it 'assigns proper credentials' do
        expect(client.credentials).to be_an_instance_of(GRPC::Core::ChannelCredentials)
      end
    end
  end
end
