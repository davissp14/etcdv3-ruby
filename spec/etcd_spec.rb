require 'spec_helper'

describe Etcd do
  context 'Insecure connection without Auth' do
    let(:conn) do
      Etcd.new(url: 'http://127.0.0.1:2379')
    end
    describe '#initialize' do
      subject { conn }
      it { is_expected.to have_attributes(scheme: 'http') }
      it { is_expected.to have_attributes(hostname: '127.0.0.1') }
      it { is_expected.to have_attributes(port: 2379) }
      it { is_expected.to have_attributes(credentials: :this_channel_is_insecure) }
      it { is_expected.to have_attributes(token: nil) }
      it { is_expected.to have_attributes(user: nil) }
      it { is_expected.to have_attributes(password: nil) }
    end

    describe '#version' do
      subject { conn.version }
      it { is_expected.to be_an_instance_of(String) }
    end

    describe '#db_size' do
      subject { conn.db_size }
      it { is_expected.to_not be_nil }
    end

    describe '#leader_id' do
      subject { conn.leader_id.class }
      it { is_expected.to_not be_nil }
    end

    describe '#disable_auth' do
      before do
        conn.add_user('root', 'test')
        conn.grant_role_to_user('root', 'root')
        conn.enable_auth
        conn.authenticate('root', 'test')
      end
      after { conn.delete_user('root') }
      subject { conn.disable_auth }
      it { is_expected.to be_an_instance_of(Etcdserverpb::AuthDisableResponse) }
    end

    describe '#enable_auth' do
      before do
        conn.add_user('root', 'test')
        conn.grant_role_to_user('root', 'root')
      end
      after do
        conn.authenticate('root', 'test')
        conn.disable_auth
        conn.delete_user('root')
      end
      subject { conn.enable_auth }
      it { is_expected.to be_an_instance_of(Etcdserverpb::AuthEnableResponse) }
    end

    describe "#authenticate" do
      context "auth enabled" do
        before do
          conn.add_user('root', 'test')
          conn.grant_role_to_user('root', 'root')
          conn.enable_auth
          conn.authenticate('root', 'test')
        end
        after do
          conn.disable_auth
          conn.delete_user('root')
        end
        it 'properly reconfigures auth and token' do
          expect(conn.token).to_not be_nil
          expect(conn.user).to eq('root')
          expect(conn.password).to eq('test')
        end
      end

      context 'auth disabled' do
        it 'raises error' do
          expect { conn.authenticate('root', 'root') }.to raise_error(GRPC::InvalidArgument)
        end
      end
    end
  end
end
