require 'spec_helper'

describe Etcd do
  context 'Insecure connection without Auth' do
    let(:conn) do
      Etcd.new(url: 'http://127.0.0.1:2379')
    end
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
  end
end
