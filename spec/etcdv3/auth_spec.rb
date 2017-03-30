# require 'spec_helper'
# require 'securerandom'
#
# describe Etcd::Auth do
#
#   context "User managment without Auth" do
#
#     let(:stub){ Etcd::Auth.new("127.0.0.1", 2379, :this_channel_is_insecure)}
#     let(:rando) { SecureRandom.hex(10) }
#
#     describe "#add_user" do
#       it 'adds user' do
#         expect(stub.add_user(rando, 'test')).to be_an_instance_of(Etcdserverpb::AuthUserAddResponse)
#       end
#     end
#
#     describe "#user_list" do
#       it 'has correct data type' do
#         expect(stub.user_list).to be_an_instance_of(Google::Protobuf::RepeatedField)
#       end
#
#       it 'contains user testy' do
#         puts stub.user_list
#         expect(stub.user_list).to eq(rando)
#       end
#     end
#
#     describe "#delete_user" do
#
#       it 'deletes user' do
#         expect(stub.delete_user(rando)).to be_an_instance_of(Etcdserverpb::AuthUserDeleteResponse)
#       end
#
#     end
#
#   end
#
# end
