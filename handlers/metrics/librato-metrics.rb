#!/usr/bin/env ruby
#
# Copyright 2013 FunGo Studios (team@fungostudios.com)
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-handler'
require 'librato/metrics'

class LibratoMetrics < Sensu::Handler
  # override filters from Sensu::Handler. not appropriate for metric handlers
  def filter
  end

  def handle
    queue = Librato::Metrics::Queue.new
    @event['check']['output'].split("\n").each do |line|
      name, value, timestamp = line.split("\t")
      queue.add name => {:measure_time => timestamp.to_i, :value => value.to_i}
    end

    Librato::Metrics.authenticate settings['librato']['email'], settings['librato']['api_key']

    begin
      timeout(3) do
        queue.submit
      end
    rescue Timeout::Error
      puts "librato -- timed out while sending metrics"
    rescue => error
      puts "librato -- failed to send metrics : #{error.message}"
      puts "  #{error.backtrace.join("\n\t")}"
    end
  end
end
