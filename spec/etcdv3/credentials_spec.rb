require 'spec_helper'

describe Etcdv3::Credentials do
  describe '#initialize' do
    context 'insecure' do
      subject { Etcdv3::Credentials.new }
      it { is_expected.to be_an_instance_of(Etcdv3::Credentials) }
    end

    context 'secure' do
      context 'valid paths' do
        subject do
          Etcdv3::Credentials.new(
            key: 'spec/fixtures/key.pem',
            cert: 'spec/fixtures/cert.pem',
            cacert: 'spec/fixtures/cacert.pem'
          )
        end
        it { is_expected.to be_an_instance_of(Etcdv3::Credentials) }
      end

      context 'invalid paths' do
        it 'cacert - raises FailedToResolveCredentials' do
          expect { Etcdv3::Credentials.new(cacert: '../path/cacer.crt') }
            .to raise_exception(Etcdv3::Credentials::FailedToResolveCredentials)
        end

        it 'key - raises FailedToResolveCredentials' do
          expect { Etcdv3::Credentials.new(key: '../path/key.crt') }
            .to raise_exception(Etcdv3::Credentials::FailedToResolveCredentials)
        end

        it 'cert - raises FailedToResolveCredentials' do
          expect { Etcdv3::Credentials.new(cert: '../path/cert.crt') }
            .to raise_exception(Etcdv3::Credentials::FailedToResolveCredentials)
        end
      end
    end
  end

  describe '#resolve' do
    let(:insecure_endpoint) { URI('http://127.0.0.1:2379') }
    let(:secure_endpoint) { URI('https://127.0.0.1:2379') }

    context 'http' do
      subject { Etcdv3::Credentials.new.resolve(insecure_endpoint) }
      it { is_expected.to eq(:this_channel_is_insecure) }
    end

    context 'https' do
      context 'no creds' do
        subject { Etcdv3::Credentials.new.resolve(secure_endpoint) }
        it { is_expected.to be_an_instance_of(GRPC::Core::ChannelCredentials) }
      end

      context 'cacert only' do
        subject do
          Etcdv3::Credentials.new(
            cacert: 'spec/fixtures/cacert.pem'
          ).resolve(secure_endpoint)
        end
        it { is_expected.to be_an_instance_of(GRPC::Core::ChannelCredentials) }
      end

      context 'key, cert, and cacert' do
        subject do
          Etcdv3::Credentials.new(
            cacert: 'spec/fixtures/cacert.pem',
            key: 'spec/fixtures/key.pem',
            cert: 'spec/fixtures/cert.pem'
          ).resolve(secure_endpoint)
        end
        it { is_expected.to be_an_instance_of(GRPC::Core::ChannelCredentials) }
      end
    end
  end
end
