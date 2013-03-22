#!/usr/bin/env ruby
#
# Push Redis INFO stats into graphite
# ===
#
# TODO: Only pass integer metrics with options for single metrics.
#
# Copyright 2012 Pete Shima <me@peteshima.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'redis'

class Redis2Graphite < Sensu::Plugin::Metric::CLI::Graphite

  option :host,
    :short => "-h HOST",
    :long => "--host HOST",
    :description => "Redis Host to connect to",
    :required => true,
    :default  => '127.0.0.1'

  option :port,
    :short => "-p PORT",
    :long => "--port PORT",
    :description => "Redis Port to connect to",
    :proc => proc {|p| p.to_i },
    :required => true,
    :default => 6379

  option :scheme,
    :description => "Metric naming scheme, text to prepend to metric",
    :short => "-s SCHEME",
    :long => "--scheme SCHEME",
    :default => "#{Socket.gethostname}.redis"

  def run    
    redis = Redis.new(:host => config[:host], :port =>config[:port])

    redis.info.each do |k, v|
      output "#{config[:scheme]}.#{k}", v
    end

    ok
  end

end
