require 'spec_helper'
require 'securerandom'


describe Etcdv3::Namespace::Watch do
  let(:stub) { local_namespace_stub(Etcdv3::Namespace::Watch, 5, '/namespace/') }
  let(:kv_stub_no_ns) { local_stub(Etcdv3::KV, 1) }
  let(:kv_stub) { local_namespace_stub(Etcdv3::Namespace::KV, 1, '/namespace/') }

  context 'watch' do
    it 'should return an event' do 
      resp = nil
      thr = Thread.new do |thr|
        resp = stub.watch("foo", nil, 1, nil)
      end
      sleep 2
      kv_stub.put("foo", "works")
      thr.join
      expect(resp).to be_an_instance_of(Google::Protobuf::RepeatedField)
      expect(resp.last.kv.key).to eq('foo')  
    end

    it 'should return event when non-namespace client writes to key' do 
      resp = nil
      thr = Thread.new do |thr|
        resp = stub.watch("foobar", nil, 1, nil)
      end
      sleep 2
      kv_stub_no_ns.put("/namespace/foobar", "works")
      thr.join
      expect(resp).to be_an_instance_of(Google::Protobuf::RepeatedField)
      expect(resp.last.kv.key).to eq('foobar')  
    end
  end
end

