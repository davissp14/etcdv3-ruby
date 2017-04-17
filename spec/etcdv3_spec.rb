require 'spec_helper'

describe Etcdv3 do
  context 'Insecure connection without Auth' do

    let(:conn) { local_connection }

    describe '#initialize' do
      context 'without auth' do
        subject { conn }
        it { is_expected.to have_attributes(scheme: 'http') }
        it { is_expected.to have_attributes(hostname: '127.0.0.1') }
        it { is_expected.to have_attributes(credentials: :this_channel_is_insecure) }
        it { is_expected.to have_attributes(token: nil) }
        it { is_expected.to have_attributes(user: nil) }
        it { is_expected.to have_attributes(password: nil) }
      end
      context 'with auth' do
        let(:auth_conn) { local_connection_with_auth('test', 'pass') }
        before do
          conn.add_user('root', 'pass')
          conn.grant_role_to_user('root', 'root')
          conn.add_user('test', 'pass')
          conn.enable_auth
        end
        after do
          conn.authenticate('root', 'pass')
          conn.disable_auth
          conn.delete_user('root')
          conn.delete_user('test')
        end
        it 'doesnt raise error' do
          expect{ auth_conn }.to_not raise_error
        end
      end
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
      subject { conn.leader_id }
      it { is_expected.to_not be_nil }
    end

    describe '#alarm_list' do
      subject { conn.alarm_list }
      it { is_expected.to_not be_nil }
    end

    describe '#deactivate_alarms' do
      subject { conn.deactivate_alarms }
      it { is_expected.to_not be_nil }
    end

    describe '#get' do
      before do
        conn.put('apple', 'test')
        conn.put('applee', 'test')
        conn.put('appleee', 'test')
      end
      context 'no filters' do
        subject { conn.get('apple') }
        it { is_expected.to_not be_nil }
      end
      context 'sorts desc' do
        subject do
          conn.get('apple', range_end: 'appleeee', sort_order: :descend) \
            .kvs.first.key
        end
        it { is_expected.to eq('appleee') }
      end
      context 'sorts asc' do
        subject do
          conn.get('apple', range_end: 'appleeee', sort_order: :ascend) \
            .kvs.first.key
        end
        it { is_expected.to eq('apple') }
      end
      context 'count only' do
        subject do
          conn.get('apple', range_end: 'appleeee', count_only: true).kvs
        end
        it { is_expected.to be_empty }
      end
    end

    describe '#put' do
      subject { conn.put('test', 'value') }
      it { is_expected.to_not be_nil }
    end

    describe '#del' do
      context 'no range' do
        before { conn.put('test', 'value') }
        subject { conn.del('test') }
        it { is_expected.to_not be_nil }
      end
      context 'ranged del' do
        before do
          conn.put('test', 'value')
          conn.put('testt', 'value')
        end
        subject { conn.del('test', range_end: 'testtt') }
        it { is_expected.to_not be_nil }
      end
    end

    describe '#watch' do
      after { conn.del('watchtest') }
      it 'fires event on put' do
        th = Thread.new { conn.watch('watchtest') }
        conn.put('watchtest', 'WoW')
        events = th.value
        th.kill
        expect(events.first.kv.value).to eq('WoW')
      end
    end

    describe '#grant_lease' do
      subject { conn.grant_lease(2) }
      it { is_expected.to_not be_nil }
    end

    describe '#revoke_lease' do
      let!(:lease_id) { conn.grant_lease(2)['ID'] }
      subject { conn.revoke_lease(lease_id) }
      it { is_expected.to_not be_nil }
    end

    describe '#lease_ttl' do
      let!(:lease_id) { conn.grant_lease(2)['ID'] }
      subject { conn.lease_ttl(lease_id) }
      it { is_expected.to_not be_nil }
    end

    describe '#add_user' do
      after { conn.delete_user('test') }
      subject { conn.add_user('test', 'user') }
      it { is_expected.to_not be_nil }
    end

    describe '#delete_user' do
      before { conn.add_user('test', 'user') }
      subject { conn.delete_user('test') }
      it { is_expected.to_not be_nil }
    end

    describe '#change_user_password' do
      before { conn.add_user('change_user', 'pass') }
      after { conn.delete_user('change_user') }
      subject { conn.change_user_password('change_user', 'new_pass') }
      it { is_expected.to_not be_nil }
    end

    describe '#user_list' do
      subject { conn.user_list }
      it { is_expected.to_not be_nil }
    end

    describe '#role_list' do
      subject { conn.role_list }
      it { is_expected.to_not be_nil }
    end

    describe '#add_role' do
      subject { conn.add_role('add_role') }
      it { is_expected.to_not be_nil }
    end

    describe '#delete_role' do
      before { conn.add_role('delete_role') }
      subject { conn.delete_role('delete_role') }
      it { is_expected.to_not be_nil }
    end

    describe '#grant_role_to_user' do
      before { conn.add_user('grant_me', 'pass') }
      subject { conn.grant_role_to_user('grant_me', 'root') }
      it { is_expected.to_not be_nil }
    end

    describe '#revoke_role_from_user' do
      subject { conn.revoke_role_from_user('grant_me', 'root') }
      it { is_expected.to_not be_nil }
    end

    describe '#grant_permission_to_role' do
      before { conn.add_role('grant') }
      subject { conn.grant_permission_to_role('grant', 'readwrite', 'a', 'Z') }
      it { is_expected.to_not be_nil }
    end

    describe '#revoke_permission_to_role' do
      subject { conn.revoke_permission_from_role('grant', 'readwrite', 'a', 'Z') }
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

    describe '#metacache' do
      context 'uses cached request object' do
        let!(:object_id) { conn.send(:request).object_id }
        before { conn.add_user('root', 'test') }
        after { conn.delete_user('root') }
        subject { conn.send(:request).object_id }
        it { is_expected.to eq(object_id) }
      end
      context 'resets cache on auth' do
        let!(:object_id) { conn.send(:request).object_id }
        before do
          conn.add_user('root', 'test')
          conn.grant_role_to_user('root', 'root')
          conn.enable_auth
          conn.authenticate('root', 'test')
          conn.add_user('boom', 'password')
        end
        after do
          conn.disable_auth
          conn.delete_user('root')
          conn.delete_user('boom')
        end
        subject { conn.send(:request).object_id }
        it { is_expected.to_not eq(object_id) }
      end
    end
  end
end
