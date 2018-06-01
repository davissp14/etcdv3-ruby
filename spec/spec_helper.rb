$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('./helpers', __FILE__)

require 'simplecov'
require 'codecov'
SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'etcdv3'
require 'helpers/test_instance'
require 'helpers/connections'
require 'helpers/shared_examples_for_timeout'

RSpec.configure do |config|
  config.include(Helpers::Connections)

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  instance = Helpers::TestInstance.new
  config.before(:suite) do
    # $stderr = File.open(File::NULL, "w")
    instance.start
  end
  config.after(:suite) do
    instance.stop
  end
end
