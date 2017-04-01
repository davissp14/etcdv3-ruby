require 'spec_helper'

describe Etcd::Maintenance do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#member_status' do
    subject { conn.member_status }

    context 'responds to correct attributes' do
      it { is_expected.to be_an_instance_of(OpenStruct) }
      it { is_expected.to respond_to(:version) }
      it { is_expected.to respond_to(:db_size) }
      it { is_expected.to respond_to(:cluster_id) }
      it { is_expected.to respond_to(:member_id) }
      it { is_expected.to respond_to(:leader_id) }
      it { is_expected.to respond_to(:raft_index) }
      it { is_expected.to respond_to(:raft_term) }
    end

    context 'sets values' do
      it { expect(subject.version).to_not be_nil }
      it { expect(subject.db_size).to_not be_nil }
      it { expect(subject.cluster_id).to_not be_nil }
      it { expect(subject.member_id).to_not be_nil }
      it { expect(subject.leader_id).to_not be_nil }
      it { expect(subject.raft_index).to_not be_nil }
      it { expect(subject.raft_term).to_not be_nil }
    end
  end
end
