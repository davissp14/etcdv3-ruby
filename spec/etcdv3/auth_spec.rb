require 'spec_helper'

describe Etcd::Auth do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#add_user' do
    after { conn.delete_user('boom') }
    subject { conn.add_user('boom', 'test') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserAddResponse) }
  end

  describe '#get_user' do
    before { conn.add_user('get_user', 'password') }
    after { conn.delete_user('get_user') }
    subject { conn.get_user('get_user') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGetResponse) }
  end

  describe '#user_list' do
    before { conn.add_user('list', 'test') }
    after { conn.delete_user('list') }
    subject { conn.user_list }
    it 'returns correcty user information' do
      expect(subject).to be_an_instance_of(Google::Protobuf::RepeatedField)
      expect(subject).to include('list')
    end
  end

  describe '#delete_user' do
    before { conn.add_user('delete_user', 'test') }
    subject { conn.delete_user('delete_user') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse) }
  end

  describe '#grant_role_to_user' do
    before { conn.add_user('grant_user', 'test') }
    after { conn.delete_user('grant_user') }
    subject { conn.grant_role_to_user('grant_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGrantRoleResponse) }
  end

  describe '#revoke_role_from_user' do
    before do
      conn.add_user('revoke_user', 'password')
      conn.grant_role_to_user('revoke_user', 'root')
    end
    after { conn.delete_user('revoke_user') }
    subject { conn.revoke_role_from_user('revoke_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserRevokeRoleResponse) }
  end

  describe '#add_role' do
    after { conn.delete_role('add_role') }
    subject { conn.add_role('add_role') }
    it 'adds a role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
      expect(conn.role_list.roles).to include('add_role')
    end
  end

  describe '#get_role' do
    before { conn.add_role('get_role') }
    after { conn.delete_role('get_role') }
    subject { conn.get_role('get_role') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleGetResponse) }
  end

  describe '#delete_role' do
    before { conn.add_role('delete_role') }
    subject { conn.delete_role('delete_role') }
    it 'deletes role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleDeleteResponse)
      expect(conn.role_list.roles).to_not include('delete_role')
    end
  end

  describe '#role_list' do
    subject { conn.role_list }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleListResponse) }
  end

  describe '#grant_permission_to_role' do
    before { conn.add_role('grant_perm') }
    after { conn.delete_role('grant_perm') }
    subject { conn.grant_permission_to_role('grant_perm', 'write', 'c', 'cc') }
    it 'sets permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleGrantPermissionResponse)
    end
  end

  describe '#revoke_permission_from_role' do
    before do
      conn.add_role('myrole')
      conn.grant_permission_to_role('myrole', 'write', 'c', 'cc')
    end
    after { conn.delete_role('myrole') }
    subject { conn.revoke_permission_from_role('myrole', 'write', 'c', 'cc') }
    it 'revokes permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleRevokePermissionResponse)
      expect(conn.get_role('myrole').perm.size).to eq(0)
    end
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

  describe '#change_user_password' do
    before { conn.add_user('myuser', 'test') }
    after { conn.delete_user('myuser') }
    subject { conn.change_user_password('myuser', 'boom') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserChangePasswordResponse) }
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
      subject { conn.authenticate('root', 'root') }
      it { is_expected.to eq(false) }
    end
  end
end
