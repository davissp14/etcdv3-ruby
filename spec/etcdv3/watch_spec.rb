require 'spec_helper'
require 'securerandom'

# Locking is not implemented in etcd v3.1.X
unless $instance.version < Gem::Version.new("3.2.0")
  describe Etcdv3::Watch do
    let(:stub) { local_stub(Etcdv3::Watch, 1) }
    let(:kv_stub) { local_stub(Etcdv3::KV, 1) }

    context 'xxx' do
      before(:each) do
        kv_stub.put 'foo', 'bar'
      end
      it_should_behave_like "a method with a GRPC timeout", described_class, :watch, :watch, 'foo', "\0", 1, nil
    end
  end
end
