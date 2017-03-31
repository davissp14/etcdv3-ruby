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
    subject { conn.add_role('add_role', 'readwrite', 'a', 'Z') }
    it 'adds a role' do
      expect(subject).to be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
      expect(conn.role_list.roles).to include('add_role')
    end
  end

  describe '#delete_role' do
    before { conn.add_role('delete_role', 'readwrite', 'a', 'Z') }
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
      subject { conn.authenticate('root', 'root') }
      it { is_expected.to eq(false) }
    end
  end
end
