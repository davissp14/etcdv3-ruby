require 'spec_helper'

describe Etcdv3::Auth do

  let(:stub) { local_stub(Etcdv3::Auth) }

  test_instance = Helpers::TestInstance.new(tls: false)

  before(:context) do
    test_instance.start
  end

  after(:context) do
    test_instance.stop
  end

  describe '#user_add' do
    after { stub.user_delete('boom') }
    subject { stub.user_add('boom', 'test') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserAddResponse) }
  end

  describe '#user_get' do
    before { stub.user_add('user_get', 'password') }
    after { stub.user_delete('user_get') }
    subject { stub.user_get('user_get') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGetResponse) }
  end

  describe '#user_list' do
    subject { stub.user_list }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserListResponse) }
  end

  describe '#user_delete' do
    before { stub.user_add('user_delete', 'test') }
    subject { stub.user_delete('user_delete') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse) }
  end

  describe '#user_grant_role' do
    before { stub.user_add('grant_user', 'test') }
    after { stub.user_delete('grant_user') }
    subject { stub.user_grant_role('grant_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserGrantRoleResponse) }
  end

  describe '#user_revoke_role' do
    before do
      stub.user_add('revoke_user', 'password')
      stub.user_grant_role('revoke_user', 'root')
    end
    after { stub.user_delete('revoke_user') }
    subject { stub.user_revoke_role('revoke_user', 'root') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserRevokeRoleResponse) }
  end

  describe '#role_add' do
    after { stub.role_delete('role_add') }
    subject { stub.role_add('role_add') }
    it 'adds a role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
      expect(stub.role_list.roles).to include('role_add')
    end
  end

  describe '#role_get' do
    before { stub.role_add('role_get') }
    after { stub.role_delete('role_get') }
    subject { stub.role_get('role_get') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleGetResponse) }
  end

  describe '#role_delete' do
    before { stub.role_add('role_delete') }
    subject { stub.role_delete('role_delete') }
    it 'deletes role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleDeleteResponse)
      expect(stub.role_list.roles).to_not include('role_delete')
    end
  end

  describe '#role_list' do
    subject { stub.role_list }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthRoleListResponse) }
  end

  describe '#role_grant_permission' do
    before { stub.role_add('grant_perm') }
    after { stub.role_delete('grant_perm') }
    subject { stub.role_grant_permission('grant_perm', :write, 'c', 'cc') }
    it 'sets permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleGrantPermissionResponse)
    end
  end

  describe '#revoke_permission_from_role' do
    before do
      stub.role_add('myrole')
      stub.role_grant_permission('myrole', :write, 'c', 'cc')
    end
    after { stub.role_delete('myrole') }
    subject { stub.role_revoke_permission('myrole', :write, 'c', 'cc') }
    it 'revokes permission' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleRevokePermissionResponse)
      expect(stub.role_get('myrole').perm.size).to eq(0)
    end
  end

  describe '#user_change_password' do
    before { stub.user_add('myuser', 'test') }
    after { stub.user_delete('myuser') }
    subject { stub.user_change_password('myuser', 'boom') }
    it { is_expected.to be_an_instance_of(Etcdserverpb::AuthUserChangePasswordResponse) }
  end

end
