require 'spec_helper'

describe Etcd::Auth do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#add_user' do
    it 'returns AuthUserAddResponse' do
      expect(conn.add_user("boom", 'test')).to \
        be_an_instance_of(Etcdserverpb::AuthUserAddResponse)
    end
  end

  describe '#user_list' do

    it 'returns Protobuf' do
      expect(conn.user_list).to \
        be_an_instance_of(Google::Protobuf::RepeatedField)
    end

    it 'returns listme user' do
      conn.add_user('listme', 'test')
      expect(conn.user_list).to include('listme')
    end
  end

  describe '#delete_user' do
    before do
      conn.add_user('testuser', 'test')
    end
    it 'returns AuthUserDeleteResponse' do
      expect(conn.delete_user('testuser')).to \
        be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse)
    end
  end

  describe '#grant_role_to_user' do
    before do
      conn.add_user('root', 'password')
    end
    after do
      conn.delete_user('root')
    end
    it 'returns AuthUserGrantRoleResponse' do
      expect(conn.grant_role_to_user("root", 'root')).to \
        be_an_instance_of(Etcdserverpb::AuthUserGrantRoleResponse)
    end
  end

  describe '#add_role' do
    it 'returns AuthRoleAddResponse' do
      expect(conn.add_role('testRole', 'readwrite', 'a', 'Z')).to \
        be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
    end
  end

  describe '#add_delete' do
    it 'returns AuthRoleAddResponse' do
      expect(conn.delete_role('testRole')).to \
        be_an_instance_of(Etcdserverpb::AuthRoleDeleteResponse)
    end
  end

  describe '#role_list' do
    it 'returns AuthRoleListResponse' do
      expect(conn.role_list).to \
        be_an_instance_of(Etcdserverpb::AuthRoleListResponse)
    end
  end

  describe '#disable_auth' do
    before do
      conn.add_user('root', 'test')
      conn.grant_role_to_user('root', 'root')
      conn.enable_auth
      conn.authenticate('root', 'test')
    end
    after do
      conn.delete_user('root')
    end
    it 'returns AuthDisableResponse' do
      expect(conn.disable_auth).to \
        be_an_instance_of(Etcdserverpb::AuthDisableResponse)
    end
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
    it 'returns AuthEnableResponse' do
      expect(conn.enable_auth).to be_an_instance_of(Etcdserverpb::AuthEnableResponse)
    end
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
      it 'properly reconfigures token + user + password' do
        expect(conn.token).to_not be_nil
        expect(conn.user).to eq('root')
        expect(conn.password).to eq('test')
      end
    end

    context 'auth disabled' do
      it 'returns false when authenticating with auth disabled' do
        expect(conn.authenticate('root', 'root')).to eq(false)
      end
    end
  end
end
