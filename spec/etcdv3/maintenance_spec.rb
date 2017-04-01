require 'spec_helper'

describe Etcd::Maintenance do

  let(:conn) do
    Etcd.new(url: 'http://127.0.0.1:2379')
  end

  describe '#version' do
    subject { conn.version }
    it { is_expected.to_not be_nil }
  end

  describe '#leader_id' do
    subject { conn.leader_id }
    it { is_expected.to_not be_nil }
  end

  describe '#db_size' do
    subject { conn.db_size }
    it { is_expected.to_not be_nil }
  end
end
