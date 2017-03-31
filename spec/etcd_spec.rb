require 'spec_helper'

describe Etcd do
  context 'Insecure connection without Auth' do
    let(:conn) do
      Etcd.new(url: 'http://127.0.0.1:2379')
    end

    describe '#initialize' do
      subject { conn }
      it { is_expected.to have_attributes(scheme: 'http') }
      it { is_expected.to have_attributes(hostname: '127.0.0.1') }
      it { is_expected.to have_attributes(port: 2379) }
      it { is_expected.to have_attributes(credentials: :this_channel_is_insecure) }
      it { is_expected.to have_attributes(token: nil) }
      it { is_expected.to have_attributes(user: nil) }
      it { is_expected.to have_attributes(password: nil) }
    end
  end
end
