require 'spec_helper'

describe Etcdv3::Lock do
  let(:stub) { local_stub(Etcdv3::Lock, 1) }

  it_should_behave_like "a method with a GRPC timeout", described_class, :unlock, :unlock, 'foo'
  #it_should_behave_like "a method with a GRPC timeout", described_class, :lock, :lock, 'foo'

  describe '#lock' do
    subject { stub.lock('foo') }
    it { is_expected.to be_an_instance_of(V3lockpb::LockResponse) }
  end

  describe '#unlock' do
    subject { stub.unlock('foo') }
    it { is_expected.to be_an_instance_of(V3lockpb::UnlockResponse) }
  end
end
