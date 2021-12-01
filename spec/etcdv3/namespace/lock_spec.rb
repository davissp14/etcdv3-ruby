require 'spec_helper'

# Locking is not implemented in etcd v3.1.X
unless $instance.version < Gem::Version.new("3.2.0")
  describe Etcdv3::Namespace::Lock do
    let(:stub) { local_namespace_stub(Etcdv3::Namespace::Lock, 1, '/namespace/') }
    let(:lease_stub) { local_stub(Etcdv3::Lease, 1) }

    # NOTE: this was running duplicate tests against Etcdv3::Lock before, but it
    # doesn't work with Etcdv3::Namespace::Lock
    #
    # it_should_behave_like "a method with a GRPC timeout", described_class, :unlock, :unlock, 'foo'

    # it_should_behave_like "a method with a GRPC timeout", described_class, :lock, :lock, 'foo'

    describe '#lock' do
      it 'returns a response' do
        lease_id = lease_stub.lease_grant(10)['ID']
        expect(stub.lock('example1', lease_id)).to(
          be_an_instance_of(V3lockpb::LockResponse)
        )
      end

      it 'passes metadata correctly' do
        lease_id = lease_stub.lease_grant(10)['ID']
        stub = expect_metadata_passthrough_namespace(described_class, :lock, :lock, '/namespace/')
        stub.lock('example2', lease_id)
      end
    end

    describe '#unlock' do
      it 'returns a response' do
        expect(stub.unlock('example3')).to be_an_instance_of(V3lockpb::UnlockResponse)
      end

      it 'passes metadata correctly' do
        stub = expect_metadata_passthrough_namespace(described_class, :unlock, :unlock, '/namespace/')
        stub.unlock('example4')
      end
    end
  end
end
