#!/usr/bin/env ruby

require 'redis'
require_relative 'lib/identifier'

redis = Redis.new
redis.sadd 'overseer:queues', ['incoming', 'dispatching']

worker = Worker.new

loop { worker.consider_working }
