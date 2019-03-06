require 'spec_helper'

describe Etcdv3::ConnectionWrapper do
  let(:conn) { local_connection }
  let(:endpoints) { ['http://localhost:2379', 'http://localhost:2389'] }

  describe '#initialize' do
    subject { Etcdv3::ConnectionWrapper.new(10, *endpoints) }
    it { is_expected.to have_attributes(user: nil, password: nil, token: nil) }
    it 'sets hostnames in correct order' do
      expect(subject.endpoints.map(&:hostname)).to eq(['localhost:2379', 'localhost:2389'])
    end
    it 'stubs connection with the correct hostname' do
      expect(subject.connection.hostname).to eq('localhost:2379')
    end
  end

  describe "#rotate_connection_endpoint" do
    subject { Etcdv3::ConnectionWrapper.new(10, *endpoints) }
    before do
      subject.rotate_connection_endpoint
    end
    it 'sets hostnames in correct order' do
      expect(subject.endpoints.map(&:hostname)).to eq(['localhost:2389', 'localhost:2379'])
    end
    it 'sets correct hostname' do
      expect(subject.connection.hostname).to eq('localhost:2389')
    end
  end

  describe "Failover Simulation" do
    let(:allow_reconnect) { true }
    let(:modified_conn) {
      local_connection(
        "http://localhost:2369, http://localhost:2379",
        allow_reconnect: allow_reconnect
      )
    }
    subject { modified_conn.get('boom') }

    context 'without auth' do
      # Set primary endpoint to a non-existing etcd endpoint
      context 'with reconnect' do
        it { is_expected.to be_an_instance_of(Etcdserverpb::RangeResponse) }
      end
      context 'without reconnect' do
        let(:allow_reconnect) { false }
        it { expect { subject }.to raise_error(GRPC::Unavailable) }
      end
    end
    context 'with auth' do
      before do
        # Establish connection with auth using real endpoint.
        modified_conn.send(:conn).rotate_connection_endpoint
        modified_conn.user_add('root', 'pass')
        modified_conn.user_grant_role('root', 'root')
        modified_conn.auth_enable
        modified_conn.authenticate('root', 'pass')
        # Rotate connections so we initiate connection using bad endpoint
        modified_conn.send(:conn).rotate_connection_endpoint
      end
      after do
        modified_conn.auth_disable
        modified_conn.user_delete('root')
      end
      context 'with reconnect' do
        it { is_expected.to be_an_instance_of(Etcdserverpb::RangeResponse) }
      end
      context 'without reconnect' do
        let(:allow_reconnect) { false }
        it { expect { subject }.to raise_error(GRPC::Unavailable) }
      end
    end
  end

  describe "GRPC::Unauthenticated recovery" do
    let(:allow_reconnect) { true }
    let(:conn) { local_connection(allow_reconnect: allow_reconnect) }
    let(:wrapper) { conn.send(:conn) }
    let(:connection) { wrapper.connection }
    before do
      conn.user_add('root', 'pass')
      conn.user_grant_role('root', 'root')
      conn.auth_enable
      conn.authenticate('root', 'pass')
      wrapper.token = "thiswontwork"
      connection.refresh_metadata(token: "thiswontwork")
    end
    after do
      conn.auth_disable
      conn.user_delete('root')
    end
    subject { conn.user_get('root') }
    context 'with reconnect' do
      it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGetResponse) }
    end
    context 'without reconnect' do
      let(:allow_reconnect) { false }
      it { expect { subject }.to raise_error(GRPC::Unauthenticated) }
    end
  end
end
