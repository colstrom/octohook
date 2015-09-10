#!/usr/bin/env ruby

require 'redis'
require 'webmachine'

require_relative 'lib/receiver'

Redis.new.sadd 'overseer:queues', 'incoming'

Webmachine.application.routes do
  add ['status'], Status
  add [:*], Webhook
end
