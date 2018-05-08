shared_examples_for "a method with a GRPC timeout" do |stub_class, method_name, expectation_target, *args|
  context "#{stub_class} timeouts for #{method_name}" do
    let(:handler) { local_stub(stub_class, 5) }
    let(:client_stub) { handler.instance_variable_get "@stub"}
    it 'uses the timeout value' do
      start_time = Time.now
      deadline_time = start_time.to_f + 5
      allow(Time).to receive(:now).and_return(start_time)

      expect(client_stub).to receive(expectation_target).with(anything, hash_including(deadline: deadline_time)).and_call_original

      handler.public_send(method_name, *args)
    end

    it "can have a seperate timeout passed in" do
      start_time = Time.now
      deadline_time = start_time.to_f + 1
      allow(Time).to receive(:now).and_return(start_time)
      expect(client_stub).to receive(expectation_target).with(anything, hash_including(deadline: deadline_time)).and_call_original
      handler.public_send(method_name, *args, timeout: 1)
    end

    it 'raises a GRPC:DeadlineExceeded if the request takes too long' do
      handler = local_stub(stub_class, -1)
      expect {handler.public_send(method_name, *args)}.to raise_error(GRPC::DeadlineExceeded)
    end
  end
end

shared_examples_for "Etcdv3 instance using a timeout" do |command, *args|
  it "raises a GRPC::DeadlineExceeded exception when it takes too long"  do
    expect do
      test_args = args.dup
      test_args.push({timeout: -1})
      conn.public_send(command, *test_args)
    end.to raise_exception(GRPC::DeadlineExceeded)
  end
  it "accepts a timeout" do
    test_args = args.dup
    test_args.push({timeout: 10})
    expect{ conn.public_send(command, *test_args) }.to_not raise_exception
  end
end
