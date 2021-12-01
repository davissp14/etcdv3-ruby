module Helpers
  module MetadataPassthrough
    include Connections

    def expect_metadata_passthrough(stub_class, method_name, expectation_target)
      metadata = { user: "foo", password: "bar" }
      handler = local_stub_with_metadata(stub_class, metadata: metadata, timeout: 1)
      inner_stub = handler.instance_variable_get("@stub")
      expect(inner_stub).to receive(expectation_target).with(anything, hash_including(metadata: metadata)).and_call_original
      return handler
    end

    def expect_metadata_passthrough_namespace(stub_class, method_name, expectation_target, namespace)
      metadata = { user: "foo", password: "bar" }
      handler = local_namespace_stub_with_metadata(stub_class, metadata: metadata, timeout: 1, namespace: namespace)
      inner_stub = handler.instance_variable_get("@stub")
      expect(inner_stub).to receive(expectation_target).with(anything, hash_including(metadata: metadata)).and_call_original
      return handler
    end
  end
end
