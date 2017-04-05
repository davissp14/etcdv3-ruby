require 'spec_helper'

describe Etcd::Auth do

  let(:stub) do
    Etcd::Auth.new("127.0.0.1", 2379, :this_channel_is_insecure, {})
  end

  describe '#add_user' do
    after { stub.delete_user('boom') }
    subject { stub.add_user('boom', 'test') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserAddResponse) }
  end

  describe '#get_user' do
    before { stub.add_user('get_user', 'password') }
    after { stub.delete_user('get_user') }
    subject { stub.get_user('get_user') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGetResponse) }
  end

  describe '#user_list' do
    subject { stub.user_list }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserListResponse) }
  end

  describe '#delete_user' do
    before { stub.add_user('delete_user', 'test') }
    subject { stub.delete_user('delete_user') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse) }
  end

  describe '#grant_role_to_user' do
    before { stub.add_user('grant_user', 'test') }
    after { stub.delete_user('grant_user') }
    subject { stub.grant_role_to_user('grant_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGrantRoleResponse) }
  end

  describe '#revoke_role_from_user' do
    before do
      stub.add_user('revoke_user', 'password')
      stub.grant_role_to_user('revoke_user', 'root')
    end
    after { stub.delete_user('revoke_user') }
    subject { stub.revoke_role_from_user('revoke_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserRevokeRoleResponse) }
  end

  describe '#add_role' do
    after { stub.delete_role('add_role') }
    subject { stub.add_role('add_role') }
    it 'adds a role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
      expect(stub.role_list.roles).to include('add_role')
    end
  end

  describe '#get_role' do
    before { stub.add_role('get_role') }
    after { stub.delete_role('get_role') }
    subject { stub.get_role('get_role') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleGetResponse) }
  end

  describe '#delete_role' do
    before { stub.add_role('delete_role') }
    subject { stub.delete_role('delete_role') }
    it 'deletes role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleDeleteResponse)
      expect(stub.role_list.roles).to_not include('delete_role')
    end
  end

  describe '#role_list' do
    subject { stub.role_list }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleListResponse) }
  end

  describe '#grant_permission_to_role' do
    before { stub.add_role('grant_perm') }
    after { stub.delete_role('grant_perm') }
    subject { stub.grant_permission_to_role('grant_perm', 'write', 'c', 'cc') }
    it 'sets permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleGrantPermissionResponse)
    end
  end

  describe '#revoke_permission_from_role' do
    before do
      stub.add_role('myrole')
      stub.grant_permission_to_role('myrole', 'write', 'c', 'cc')
    end
    after { stub.delete_role('myrole') }
    subject { stub.revoke_permission_from_role('myrole', 'write', 'c', 'cc') }
    it 'revokes permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleRevokePermissionResponse)
      expect(stub.get_role('myrole').perm.size).to eq(0)
    end
  end

  describe '#change_user_password' do
    before { stub.add_user('myuser', 'test') }
    after { stub.delete_user('myuser') }
    subject { stub.change_user_password('myuser', 'boom') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserChangePasswordResponse) }
  end

end
