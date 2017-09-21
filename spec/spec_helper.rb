$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('./helpers', __FILE__)

require 'etcdv3'
require 'simplecov'
require 'codecov'
require 'helpers/test_instance'
require 'helpers/connections'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::Codecov

RSpec.configure do |config|
  config.include(Helpers::Connections)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups


  $etcd_port = ENV.fetch('ETCD_TEST_PORT', 2379).to_i
  $etcd_tls_port = ENV.fetch('ETCD_TEST_TLS_PORT', 2379+10).to_i

  instance = Helpers::TestInstance.new(port: $etcd_port)
  tls_instance = Helpers::TestInstance.new(tls: true, port: $etcd_tls_port)

  config.before(:suite) do
    instance.start
    tls_instance.start
  end
  config.after(:suite) do
    instance.stop
    tls_instance.stop
  end
end
