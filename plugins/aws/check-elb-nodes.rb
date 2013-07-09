#!/usr/bin/env ruby
#
# Checks the number of in service nodes in an AWS ELB
# ===
#
# DESCRIPTION:
#   This plugin checks an AWS Elastic Load Balancer to ensure a minimum number
#   or percentage of nodes are InService on the ELB
#
# PLATFORMS:
#   all
#
# DEPENDENCIES:
#   sensu-plugin >= 1.5 Ruby gem
#   aws-sdk Ruby gem
#
# Copyright (c) 2013, Justin Lambert <jlambert@letsevenup.com>
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require 'aws-sdk'

class SQSMsgs < Sensu::Plugin::Check::CLI

  option :aws_access_key,
    :short => '-a AWS_ACCESS_KEY',
    :long => '--aws-access-key AWS_ACCESS_KEY',
    :description => "AWS Access Key. Either set ENV['AWS_ACCESS_KEY_ID'] or provide it as an option",
    :required => true

  option :aws_secret_access_key,
    :short => '-s AWS_SECRET_ACCESS_KEY',
    :long => '--aws-secret-access-key AWS_SECRET_ACCESS_KEY',
    :description => "AWS Secret Access Key. Either set ENV['AWS_SECRET_ACCESS_KEY'] or provide it as an option",
    :required => true

  option :load_balancer,
    :short => '-n ELB_NAME',
    :long => '--name ELB_NAME',
    :description => 'The name of the ELB',
    :required => true

  option :warn_under,
    :short  => '-w WARN_NUM',
    :long  => '--warn WARN_NUM',
    :description => 'Minimum number of nodes InService on the ELB to be considered a warning',
    :default => -1,
    :proc => proc { |a| a.to_i }

  option :crit_under,
    :short  => '-c CRIT_NUM',
    :long  => '--crit CRIT_NUM',
    :description => 'Minimum number of nodes InService on the ELB to be considered critical',
    :default => -1,
    :proc => proc { |a| a.to_i }

  option :warn_percent,
    :short => '-W WARN_PERCENT',
    :long => '--warn_perc WARN_PERCENT',
    :description => 'Warn when the percentage of InService nodes is at or below this number',
    :default => -1,
    :proc => proc { |a| a.to_i }

  option :crit_percent,
    :short => '-C CRIT_PERCENT',
    :long => '--crit_perc CRIT_PERCENT',
    :description => 'Minimum percentage of nodes needed to be InService',
    :default => -1,
    :proc => proc { |a| a.to_i }

  def run
    elb = AWS::ELB.new(
      :access_key_id      => config[:aws_access_key],
      :secret_access_key  => config[:aws_secret_access_key])

    begin
      instances = elb.load_balancers[config[:load_balancer]].instances.health
    rescue AWS::ELB::Errors::LoadBalancerNotFound
      unknown "A load balancer with the name '#{config[:load_balancer]}' was not found"
    end

    num_instances = instances.count
    state = { 'OutOfService' => [], 'InService' => []}
    instances.each do |instance|
      state[instance[:state]] << instance[:instance].id
    end

    message = "InService: #{state['InService'].count}"
    if state['InService'].count > 0
      message << " (#{state['InService'].join(', ')})"
    end
    message << "; OutOfService: #{state['OutOfService'].count}"
    if state['OutOfService'].count > 0
      message << " (#{state['OutOfService'].join(', ')})"
    end

    if (config[:crit_under] > 0 && config[:crit_under] >= state['InService'].count) || (config[:crit_percent] > 0 && config[:crit_percent] >= (num_instances / state['InService'].count) * 100 )
      critical message
    elsif (config[:warn_under] > 0 && config[:warn_under] >= state['InService'].count) || (config[:warn_percent] > 0 && config[:warn_percent] >= (num_instances / state['InService'].count) * 100 )
      warning message
    else
      ok message
    end
  end
end
