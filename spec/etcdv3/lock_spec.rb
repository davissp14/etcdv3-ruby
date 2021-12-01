require 'spec_helper'

# Locking is not implemented in etcd v3.1.X
unless $instance.version < Gem::Version.new("3.2.0")
  describe Etcdv3::Lock do
    let(:stub) { local_stub(Etcdv3::Lock, 1) }
    let(:lease_stub) { local_stub(Etcdv3::Lease, 1) }

    it_should_behave_like "a method with a GRPC timeout", described_class, :unlock, :unlock, 'foo'
    #it_should_behave_like "a method with a GRPC timeout", described_class, :lock, :lock, 'foo'

    describe '#lock' do
      it 'returns a response' do
        lease_id = lease_stub.lease_grant(10)['ID']

        expect(stub.lock('example1', lease_id)).to be_an_instance_of(V3lockpb::LockResponse)
      end

      it 'passes metadata correctly' do
        lease_id = lease_stub.lease_grant(10)['ID']
        stub = expect_metadata_passthrough(described_class, :lock, :lock)
        stub.lock('example2', lease_id)
      end
    end

    describe '#unlock' do
      it 'returns a response' do
        expect(stub.unlock('example3')).to be_an_instance_of(V3lockpb::UnlockResponse)
      end

      it 'passes metadata correctly' do
        stub = expect_metadata_passthrough(described_class, :unlock, :unlock)
        stub.unlock('example4')
      end
    end
  end
end
