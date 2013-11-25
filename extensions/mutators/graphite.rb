#!/usr/bin/env ruby
#
# This is a drop-in replacement for the graphite mutator written
# as a Sensu Extention for better performance.
#
# It transforms parameter name if it's a hostname.
#
# There are two transforms you can choose:
#    * Replace dots in FQDN to underscores (default)
#      e.g. foo.example.com -> foo_example_com
#    * Output the hostname in reverse order. (reverse mode)
#      e.g. foo.example.com -> com.example.foo
#
# To enable the reverse mode, put this snippet in your configurations:
#
#    {
#      "graphite": {
#        "reverse": true
#      }
#    }
#
# Copyright 2013 Mitsutoshi Aoe <maoe@foldr.in>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

module Sensu::Extension
  class Graphite < Mutator
    def name
      'graphite'
    end

    def description
      'OnlyCheckOutput mutator for Graphite'
    end

    def post_init
      @reverse_mode = false
      if settings['graphite']
        if settings['graphite']['reverse'] == true
          @reverse_mode = true
        end
      end
    end

    def run(event, &block)
      client_name = event[:client][:name]
      if @reverse_mode
        renamed_client_name = client_name.split('.').reverse.join('.')
      else
        renamed_client_name = client_name.gsub('.', '_')
      end
      mutated = event[:check][:output].gsub(client_name, renamed_client_name)
      block.call(mutated, 0)
    end
  end
end
