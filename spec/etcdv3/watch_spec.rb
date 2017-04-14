require 'spec_helper'

describe Etcdv3::Watch do
  let(:stub) { local_stub(Etcdv3::Watch) }
  let(:kv_stub) { local_stub(Etcdv3::KV) }

  describe '#watch' do

    context 'without block' do
      after { kv_stub.del('test') }
      it 'fires event on put' do
        th = Thread.new { stub.watch('test', '') }
        kv_stub.put('test', 'value')
        expect(th.value).to be_an_instance_of(Google::Protobuf::RepeatedField)
      end
    end

    context 'with block' do
      after { kv_stub.del('bloop') }
      it 'fires multiple events' do
        queue = Queue.new
        th = Thread.new do
          stub.watch('bloop', '') do |events|
            queue.push(events)
          end
        end
        kv_stub.put('bloop', 'test1')
        kv_stub.put('bloop', 'test2')
        kv_stub.put('bloop', 'test3')
        th.kill
        expect(queue.length).to eq(3)
      end
    end
  end
end
