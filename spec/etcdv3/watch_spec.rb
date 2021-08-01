require 'spec_helper'
require 'securerandom'

# Locking is not implemented in etcd v3.1.X
unless $instance.version < Gem::Version.new("3.2.0")
  describe Etcdv3::Watch do
    let(:stub) { local_stub(Etcdv3::Watch, 5) }
    let(:kv_stub) { local_stub(Etcdv3::KV, 1) }

    context 'watch' do
      it 'should return an event' do 
        resp = nil
        thr = Thread.new do |thr|
          resp = stub.watch("foo", nil, 1, nil)
        end
        sleep 2
        kv_stub.put("foo", "works")
        thr.join
        puts resp.class
        expect(resp).to be_an_instance_of(Google::Protobuf::RepeatedField)
        expect(resp.last.kv.key).to eq('foo')  
      end
    end
  end
end
