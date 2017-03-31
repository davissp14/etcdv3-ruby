require 'spec_helper'

describe Etcd::Auth do

  let(:stub) do
    Etcd::Auth.new('127.0.0.1', 2379, :this_channel_is_insecure)
  end

  describe '#add_user' do
    it 'returns AuthUserAddResponse' do
      expect(stub.add_user("boom", 'test')).to \
        be_an_instance_of(Etcdserverpb::AuthUserAddResponse)
    end
  end

  describe '#user_list' do

    it 'returns Protobuf' do
      expect(stub.user_list).to \
        be_an_instance_of(Google::Protobuf::RepeatedField)
    end

    it 'returns listme user' do
      stub.add_user('listme', 'test')
      expect(stub.user_list).to include('listme')
    end
  end

  describe '#delete_user' do
    before do
      stub.add_user('testuser', 'test')
    end
    it 'returns AuthUserDeleteResponse' do
      expect(stub.delete_user('testuser')).to \
        be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse)
    end
  end

  describe '#grant_role_to_user' do
    before do
      stub.add_user('root', 'password')
    end
    after do
      stub.delete_user('root')
    end
    it 'returns AuthUserGrantRoleResponse' do
      expect(stub.grant_role_to_user("root", 'root')).to \
        be_an_instance_of(Etcdserverpb::AuthUserGrantRoleResponse)
    end
  end

  describe '#add_role' do
    it 'returns AuthRoleAddResponse' do
      expect(stub.add_role('testRole', 'readwrite', 'a', 'Z')).to \
        be_an_instance_of(Etcdserverpb::AuthRoleAddResponse)
    end
  end

  describe '#add_delete' do
    it 'returns AuthRoleAddResponse' do
      expect(stub.delete_role('testRole')).to \
        be_an_instance_of(Etcdserverpb::AuthRoleDeleteResponse)
    end
  end

  describe '#role_list' do
    it 'returns AuthRoleListResponse' do
      expect(stub.role_list).to \
        be_an_instance_of(Etcdserverpb::AuthRoleListResponse)
    end
  end

  describe '#disable_auth' do
    before do
      stub.add_user('root', 'test')
      stub.grant_role_to_user('root', 'root')
      stub.enable_auth
    end
    after do
      stub.delete_user('root')
    end
    it 'returns AuthDisableResponse' do
      token = stub.generate_token('root', 'test')
      expect(stub.disable_auth(token: token)).to \
        be_an_instance_of(Etcdserverpb::AuthDisableResponse)
    end
  end

  describe '#enable_auth' do
    before do
      stub.add_user('root', 'test')
      stub.grant_role_to_user('root', 'root')
    end
    after do
      token = stub.generate_token('root', 'test')
      stub.disable_auth(token: token)
      stub.delete_user('root')
    end
    it 'returns AuthEnableResponse' do
      expect(stub.enable_auth).to be_an_instance_of(Etcdserverpb::AuthEnableResponse)
    end
  end
end
