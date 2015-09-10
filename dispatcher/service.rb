#!/usr/bin/env ruby

require 'redis'
require 'multi_json'
require 'time'

require_relative 'lib/dispatcher'

Redis.new.sadd 'overseer:queues', ['dispatching', 'pending', 'tracking', 'reporting']

# POST a job to Jenkins, expect a Location header for the queue item.
Thread.new do
  worker = Pipeline::Worker.new 'dispatching', 'pending'
  worker.work do |id, spec|
    job = Jenkins.dispatch Jenkins::Job.new spec
    job.on_complete do |response|
      worker.redis.incr "dispatching:task:#{id}:response:#{response.code}"
      next unless response.success?
      worker.intake.complete id
      worker.redis.hset "dispatching:task:#{id}", 'finished', Time.now.utc.iso8601
      worker.output.add spec.merge({
                                     'url' => response.headers['Location'],
                                     'created' => Time.now.utc.iso8601
                                   })
      GitHub.update_status spec, 'pending'
    end
    job.run
  end
end

# Poll the queue, until the job has been assigned. Grab the URL to the build.
Thread.new do
  worker = Pipeline::Worker.new 'pending', 'tracking'
  worker.work do |id, spec|
    job = Jenkins.poll spec['url']
    job.on_complete do |response|
      worker.intake.complete(id) if worker.redis.get("pending:task:#{id}:response:201")
      worker.redis.incr "pending:task:#{id}:response:#{response.code}"
      next unless response.success?
      payload = MultiJson.load response.body
      if payload['executable']
        worker.intake.complete id
        worker.redis.hset "pending:task:#{id}", 'finished', Time.now.utc.iso8601
        worker.output.add spec.merge({
                                       'url' => payload['executable']['url'],
                                       'created' => Time.now.utc.iso8601
                                     })
      end
    end
    job.run
  end
end

# Poll the build. When we have a status, drop it in the reporting queue.
Thread.new do
  worker = Pipeline::Worker.new 'tracking', 'reporting'
  worker.work do |id, spec|
    job = Jenkins.poll spec['url']
    job.on_complete do |response|
      worker.redis.incr "tracking:task:#{id}:response:#{response.code}"
      next unless response.success?
      payload = MultiJson.load response.body
      if payload['result']
        worker.intake.complete id
        worker.redis.hset "tracking:task:#{id}", 'finished', Time.now.utc.iso8601
        worker.output.add spec.merge({
                                       'status' => payload['result'],
                                       'created' => Time.now.utc.iso8601
                                     })
      end
    end
    job.run
  end
end

Thread.list.reject { |t| t == Thread.current }.each(&:join)
