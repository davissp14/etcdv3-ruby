require 'fileutils'
require 'tmpdir'
require 'socket'
require 'timeout'
require 'helpers/connections'

module Helpers
  class TestInstance
    include Helpers::Connections

    class InvalidVersionException < StandardError; end
    class PortInUseException < StandardError; end

    MINIMUM_VERSION = Gem::Version.new('3.0.0')

    attr_accessor :version

    def initialize
      @pids = []
      @tmpdir = Dir.mktmpdir
      @bin = discover_binary_path
      @version = discover_binary_version

      raise InvalidVersionException if @version < MINIMUM_VERSION
      raise PortInUseException if port_open?

    rescue InvalidVersionException
      puts "Invalid Etcd Version: #{@version}. Must be running 3.0+"
      exit(1)
    rescue PortInUseException
      puts "Port #{port} is already in use. To choose a new port: `export ETCD_TEST_PORT=new_port`"
      exit(1)
    end

    def start
      raise "Already running etcd servers(#{@pids.inspect})" unless @pids.empty?
      puts "Starting up testing environment on port #{port}..."
      @pids << spawn_etcd_instance
      sleep(5)
    end

    def spawn_etcd_instance
      peer_url = "http://127.0.0.1:#{port+1}"
      client_url = "http://127.0.0.1:#{port}"
      cluster_url = "node=http://127.0.0.1:#{port+1}"
      flags =  ' --name=node'
      flags << " --initial-advertise-peer-urls=#{peer_url}"
      flags << " --listen-peer-urls=#{peer_url}"
      flags << " --listen-client-urls=#{client_url}"
      flags << " --advertise-client-urls=#{client_url}"
      flags << " --initial-cluster=#{cluster_url}"
      flags << " --data-dir=#{@tmpdir} "

      # Assumes etcd is in PATH
      command = "ETCDCTL_API=3 #{@bin} " + flags
      pid = spawn(command, out: '/dev/null', err: '/dev/null')
      Process.detach(pid)
      pid
    end

    def stop
      @pids.each { |pid| Process.kill('TERM', pid) } rescue nil
      FileUtils.remove_entry_secure(@tmpdir, true)
      @pids.clear
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

    def port_open?(seconds=1)
      Timeout::timeout(seconds) do
        begin
          TCPSocket.new('127.0.0.1', port).close
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
