require 'fileutils'
require 'tmpdir'

module Helpers
  class TestInstance

    def initialize
      @pids = []
      @tmpdir = Dir.mktmpdir
      @bin = discover_binary_path!

      verify_version_compatibility!
    end

    def start
      raise "Already running etcd servers(#{@pids.inspect})" unless @pids.empty?
      puts "Starting up testing environment..."
      @pids << spawn_etcd_instance
      sleep(5)
    end

    def spawn_etcd_instance
      peer_url = "http://127.0.0.1:2380"
      client_url = "http://127.0.0.1:2379"
      cluster_url = "node=http://127.0.0.1:2380"
      flags =  " --name=node"
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
      @pids.each{|pid| Process.kill('TERM', pid) }
      FileUtils.remove_entry_secure(@tmpdir, true)
      @pids.clear
    end

    def discover_binary_path!
      if File.exists?('/usr/local/bin/etcd')
        '/usr/local/bin/etcd'
      elsif !!ENV['ETCD_BIN_PATH']
        ENV['ETCD_BIN_PATH']
      else
        puts "Could not determine path to ETCD. Please `export ETCD_BIN_PATH=/path/to/etcd`"
      end
    end

    def verify_version_compatibility!
      result = `#{@bin} --version | grep "etcd Version"`
      version = Gem::Version.new(result.split(':').last.strip)
      if version < Gem::Version.new("3.0.0")
        puts "Invalid Etcd Version: #{version}. Must be running 3.0+"
        exit(1)
      end
    end
  end
end
