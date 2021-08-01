require 'spec_helper'

describe Etcdv3::Connection do

  describe '#initialize - without metadata' do
    subject { Etcdv3::Connection.new('http://localhost:2379', 10, nil) }

    it { is_expected.to have_attributes(endpoint: URI('http://localhost:2379')) }
    it { is_expected.to have_attributes(credentials: :this_channel_is_insecure) }
    it { is_expected.to have_attributes(hostname: 'localhost:2379') }

    [:kv, :maintenance, :lease, :watch, :auth].each do |handler|
      let(:handler_stub) { subject.handlers[handler].instance_variable_get(:@stub) }
      let(:handler_metadata) { subject.handlers[handler].instance_variable_get(:@metadata) }
      it 'sets hostname' do
        expect(handler_stub.instance_variable_get(:@host)).to eq('localhost:2379')
      end
      it 'sets token' do
        expect(handler_metadata[:token]).to be_nil
      end
    end
  end

  describe '#initialize - with metadata' do
    subject { Etcdv3::Connection.new('http://localhost:2379', 10, nil, token: 'token123') }

    [:kv, :maintenance, :lease, :watch, :auth].each do |handler|
      let(:handler_stub) { subject.handlers[handler].instance_variable_get(:@stub) }
      let(:handler_metadata) { subject.handlers[handler].instance_variable_get(:@metadata) }
      it 'sets hostname' do
        expect(handler_stub.instance_variable_get(:@host)).to eq('localhost:2379')
      end
      it 'sets token' do
        expect(handler_metadata[:token]).to eq('token123')
      end
    end
  end

  describe '#refresh_metadata' do
    subject { Etcdv3::Connection.new('http://localhost:2379', nil, token: 'token123') }
    before { subject.refresh_metadata(token: 'newtoken') }
    [:kv, :maintenance, :lease, :watch, :auth].each do |handler|
      let(:handler_metadata) { subject.handlers[handler].instance_variable_get(:@metadata) }
      it 'rebuilds handlers with new token' do
        expect(handler_metadata[:token]).to eq('newtoken')
      end
    end
  end
end
