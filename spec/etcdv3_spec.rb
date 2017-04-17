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
          conn.user_add('root', 'pass')
          conn.user_grant_role('root', 'root')
          conn.user_add('test', 'pass')
          conn.auth_enable
        end
        after do
          conn.authenticate('root', 'pass')
          conn.auth_disable
          conn.user_delete('root')
          conn.user_delete('test')
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

    describe '#alarm_deactivate' do
      subject { conn.alarm_deactivate }
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

    describe '#lease_grant' do
      subject { conn.lease_grant(2) }
      it { is_expected.to_not be_nil }
    end

    describe '#lease_revoke' do
      let!(:lease_id) { conn.lease_grant(2)['ID'] }
      subject { conn.lease_revoke(lease_id) }
      it { is_expected.to_not be_nil }
    end

    describe '#lease_ttl' do
      let!(:lease_id) { conn.lease_grant(2)['ID'] }
      subject { conn.lease_ttl(lease_id) }
      it { is_expected.to_not be_nil }
    end

    describe '#user_add' do
      after { conn.user_delete('test') }
      subject { conn.user_add('test', 'user') }
      it { is_expected.to_not be_nil }
    end

    describe '#user_delete' do
      before { conn.user_add('test', 'user') }
      subject { conn.user_delete('test') }
      it { is_expected.to_not be_nil }
    end

    describe '#user_change_password' do
      before { conn.user_add('change_user', 'pass') }
      after { conn.user_delete('change_user') }
      subject { conn.user_change_password('change_user', 'new_pass') }
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

    describe '#role_add' do
      subject { conn.role_add('role_add') }
      it { is_expected.to_not be_nil }
    end

    describe '#role_delete' do
      before { conn.role_add('role_delete') }
      subject { conn.role_delete('role_delete') }
      it { is_expected.to_not be_nil }
    end

    describe '#user_grant_role' do
      before { conn.user_add('grant_me', 'pass') }
      subject { conn.user_grant_role('grant_me', 'root') }
      it { is_expected.to_not be_nil }
    end

    describe '#user_revoke_role' do
      subject { conn.user_revoke_role('grant_me', 'root') }
      it { is_expected.to_not be_nil }
    end

    describe '#role_grant_permission' do
      before { conn.role_add('grant') }
      subject { conn.role_grant_permission('grant', :readwrite, 'a', 'Z') }
      it { is_expected.to_not be_nil }
    end

    describe '#revoke_permission_to_role' do
      subject { conn.role_revoke_permission('grant', :readwrite, 'a', 'Z') }
      it { is_expected.to_not be_nil }
    end

    describe '#auth_disable' do
      before do
        conn.user_add('root', 'test')
        conn.user_grant_role('root', 'root')
        conn.auth_enable
        conn.authenticate('root', 'test')
      end
      after { conn.user_delete('root') }
      subject { conn.auth_disable }
      it { is_expected.to be_an_instance_of(Etcdserverpb::AuthDisableResponse) }
    end

    describe '#auth_enable' do
      before do
        conn.user_add('root', 'test')
        conn.user_grant_role('root', 'root')
      end
      after do
        conn.authenticate('root', 'test')
        conn.auth_disable
        conn.user_delete('root')
      end
      subject { conn.auth_enable }
      it { is_expected.to be_an_instance_of(Etcdserverpb::AuthEnableResponse) }
    end

    describe "#authenticate" do
      context "auth enabled" do
        before do
          conn.user_add('root', 'test')
          conn.user_grant_role('root', 'root')
          conn.auth_enable
          conn.authenticate('root', 'test')
        end
        after do
          conn.auth_disable
          conn.user_delete('root')
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
        before { conn.user_add('root', 'test') }
        after { conn.user_delete('root') }
        subject { conn.send(:request).object_id }
        it { is_expected.to eq(object_id) }
      end
      context 'resets cache on auth' do
        let!(:object_id) { conn.send(:request).object_id }
        before do
          conn.user_add('root', 'test')
          conn.user_grant_role('root', 'root')
          conn.auth_enable
          conn.authenticate('root', 'test')
          conn.user_add('boom', 'password')
        end
        after do
          conn.auth_disable
          conn.user_delete('root')
          conn.user_delete('boom')
        end
        subject { conn.send(:request).object_id }
        it { is_expected.to_not eq(object_id) }
      end
    end
  end
end
