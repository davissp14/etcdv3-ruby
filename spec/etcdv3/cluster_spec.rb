require 'spec_helper'

describe Etcdv3::Cluster do

  let(:stub) { local_stub(Etcdv3::Cluster) }

  describe '#member_list' do
    subject { stub.member_list }
    it 'does' do
      puts subject.inspect
    end
    it { is_expected.to be_an_instance_of(Etcdserverpb::MemberListResponse) }
  end

end
