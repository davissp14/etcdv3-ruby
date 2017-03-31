require 'fileutils'
require 'tmpdir'

module Helpers
  class TestInstance
    MINIMUM_VERSION = Gem::Version.new('3.0.0')

    def initialize
      @pids = []
      @tmpdir = Dir.mktmpdir
      @bin = discover_binary_path
      @version = discover_binary_version

      raise "Invalid Etcd Version: #{@version}. Must be running 3.0+" \
        if @version < MINIMUM_VERSION
    end

    def start
      raise "Already running etcd servers(#{@pids.inspect})" unless @pids.empty?
      puts 'Starting up testing environment...'
      @pids << spawn_etcd_instance
      sleep(5)
    end

    def spawn_etcd_instance
      peer_url = 'http://127.0.0.1:2380'
      client_url = 'http://127.0.0.1:2379'
      cluster_url = 'node=http://127.0.0.1:2380'
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
      @pids.each { |pid| Process.kill('TERM', pid) }
      FileUtils.remove_entry_secure(@tmpdir, true)
      @pids.clear
    end

    def discover_binary_path
      'etcd'
    end

    def discover_binary_version
      result = `#{@bin} --version | grep "etcd Version"`
      Gem::Version.new(result.split(':').last.strip)
    end
  end
end
