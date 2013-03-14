#!/usr/bin/env ruby
#
# Pull MongoDB Stats to Graphite
# ===
# Copyright 2013 github.com/foomatty
# Basics from github.com/mantree/mongodb-graphite-metrics
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'mongo'
include Mongo

class MongoDB < Sensu::Plugin::Metric::CLI::Graphite

  option :host,
    :description => "MongoDB host",
    :long => "--host HOST",
    :default => "localhost"
    
  option :port,
    :description => "MongoDB port",
    :long => "--port PORT",
    :default => 27017
  
  option :user,
    :description => "MongoDB user",
    :long => "--user USER",
    :default => nil
  
  option :password,
    :description => "MongoDB password",
    :long => "--password PASSWORD",
    :default => nil
    
  def run
    host = config[:host]
    port = config[:port]
    db_name = 'admin'
    db_user = config[:user]
    db_password = config[:password]
    
    mongo_client = MongoClient.new(host,port)
    @db = mongo_client.db(db_name)
    @db.authenticate(db_user, db_password) unless db_user.nil?
    
    @isMaster = {"isMaster" => 1}
    begin
      metrics = Hash.new
      @db.command(@isMaster)["ok"] == 1
      serverStatus = @db.command('serverStatus' => 1)
      if serverStatus["ok"] == 1
        metrics.update(gatherReplicationMetrics(serverStatus))
        timestamp = Time.now.to_i
        metrics.each do |k, v|
          name = "servers.#{host}.mongodb"
          output [name, k].join("."), v, timestamp
        end
      end
      ok
    rescue
      exit(1)
    end
  end
  
  def gatherReplicationMetrics(serverStatus)
    serverMetrics = Hash.new
    serverMetrics['lock.ratio'] = "#{sprintf( "%.5f", serverStatus['globalLock']['ratio'])}"
    serverMetrics['lock.queue.total'] = serverStatus['globalLock']['currentQueue']['total']
    serverMetrics['lock.queue.readers'] = serverStatus['globalLock']['currentQueue']['readers']
    serverMetrics['lock.queue.writers'] = serverStatus['globalLock']['currentQueue']['writers']
  
    serverMetrics['connections.current'] = serverStatus['connections']['current']
    serverMetrics['connections.available'] = serverStatus['connections']['available']
  
    serverMetrics['indexes.missRatio'] = "#{sprintf( "%.5f", serverStatus['indexCounters']['btree']['missRatio'])}"
    serverMetrics['indexes.hits'] = serverStatus['indexCounters']['btree']['hits']
    serverMetrics['indexes.misses'] = serverStatus['indexCounters']['btree']['misses']
  
    serverMetrics['cursors.open'] = serverStatus['cursors']['totalOpen']
    serverMetrics['cursors.timedOut'] = serverStatus['cursors']['timedOut']
  
    serverMetrics['mem.residentMb'] = serverStatus['mem']['resident']
    serverMetrics['mem.virtualMb'] = serverStatus['mem']['virtual']
    serverMetrics['mem.mapped'] = serverStatus['mem']['mapped']
    serverMetrics['mem.pageFaults'] = serverStatus['extra_info']['page_faults']
  
    serverMetrics['asserts.warnings'] = serverStatus['asserts']['warning']
    serverMetrics['asserts.errors'] = serverStatus['asserts']['msg']
    return serverMetrics
  end

end
