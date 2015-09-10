#!/usr/bin/env ruby

require 'redis'
require_relative 'lib/identifier'

redis = Redis.new
redis.sadd 'overseer:queues', ['incoming-push', 'incoming-pull_request', 'dispatching']

Thread.new do
  worker = PullRequestWorker.new
  loop { worker.consider_working }
end

Thread.new do
  worker = PushWorker.new
  loop { worker.consider_working }
end

Thread.list.reject { |t| t == Thread.current }.each(&:join)
