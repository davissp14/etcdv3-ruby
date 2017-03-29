require 'spec_helper'

describe Etcd::Auth do

  describe '#initialize' do
    let(:stub) { Etcd::Auth.new('127.0.0.1', 2379, :this_channel_is_insecure) }

    it 'properly intializes' do
      expect(stub).to be_an_instance_of(Etcd::Auth)
    end
  end

end
