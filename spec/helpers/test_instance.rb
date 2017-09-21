require 'fileutils'
require 'tmpdir'
require 'socket'
require 'timeout'
require 'helpers/connections'

module Helpers
  class TestInstance

    class InvalidVersionException < StandardError; end
    class PortInUseException < StandardError; end

    MINIMUM_VERSION = Gem::Version.new('3.0.0')

    def initialize(options={})
      @pids = []
      @tmpdir = Dir.mktmpdir
      @bin = discover_binary_path
      @version = discover_binary_version
      @port = options.fetch(:port)
      @tls = options.fetch(:tls) { false }

      raise InvalidVersionException if @version < MINIMUM_VERSION
      raise PortInUseException if port_open?(@port)

    rescue InvalidVersionException
      puts "Invalid Etcd Version: #{@version}. Must be running 3.0+"
      exit(1)
    rescue PortInUseException
      puts "Port #{@port} is already in use. To choose a new port: `export ETCD_TEST_PORT=new_port`"
      exit(1)
    end

    def start
      puts "Starting up testing environment on port #{@port}..."
      raise "Already running etcd servers(#{@pids.inspect})" unless @pids.empty?
      @pids << spawn_etcd_instance
      sleep(5)
    end

    def spawn_etcd_instance
      if @tls
        client_url = "https://localhost:#{@port}"
        advertise_client_url = "https://localhost:#{@port}"
      else
        client_url = "http://localhost:#{@port}"
        advertise_client_url = "http://localhost:#{@port}"
      end

      peer_url = "http://localhost:#{@port+1}"
      cluster_url = "node=http://localhost:#{@port+1}"
      flags =  ' --name=node'
      flags << " --initial-advertise-peer-urls=#{peer_url}"
      flags << " --listen-peer-urls=#{peer_url}"
      flags << " --listen-client-urls=#{client_url}"
      flags << " --advertise-client-urls=#{client_url}"
      flags << " --initial-cluster=#{cluster_url}"
      flags << " --data-dir=#{@tmpdir} "

      if @tls
        flags << " --cert-file=spec/fixtures/cert.pem "
        flags << " --key-file=spec/fixtures/key.pem "
        flags << " --trusted-ca-file=spec/fixtures/cacert.pem "
      end

      # Assumes etcd is in PATH
      command = "ETCDCTL_API=3 #{@bin} " + flags
      pid = spawn(command, out: '/tmp/etcd.log', err: '/tmp/etcd.err')
      Process.detach(pid)
      pid
    end

    def stop
      puts "Stopping testing environment on port #{@port}..."
      @pids.each { |pid| Process.kill('KILL', pid) } rescue nil
      FileUtils.remove_entry_secure(@tmpdir, true)
      @pids.clear
      sleep(5)
    end

    private

    def discover_binary_path
      'etcd'
    end

    def discover_binary_version
      result = `#{@bin} --version | grep "etcd Version"`
      Gem::Version.new(result.split(':').last.strip)
    rescue
      puts "The etcd binary is not in $PATH. Export it, and try again."
      exit(1)
    end

    def port_open?(port, seconds=1)
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new('localhost', port).close
          true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          false
        end
      end
    rescue Timeout::Error
      false
    end

  end
end
