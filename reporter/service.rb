#!/usr/bin/env ruby

require 'redis'
require 'kanban'

require_relative 'lib/reporter'

redis = Redis.new
redis.sadd 'overseer:queues', 'reporting'

reporting = Kanban::Backlog.new backend: Redis.new, namespace: 'reporting'

loop do
  id = reporting.claim
  spec = reporting.get id
  GitHub.update_status spec, Jenkins::Translate.to_github(spec['status'])
  reporting.complete id
end
