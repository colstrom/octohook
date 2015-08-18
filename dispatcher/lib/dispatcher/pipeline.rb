require 'redis'
require 'kanban'

module Pipeline
  class Worker
    def initialize(in_queue, out_queue)
      @in_queue = in_queue
      @out_queue = out_queue
    end

    def redis
      @redis ||= Redis.new
    end

    def intake
      @intake ||= Kanban::Backlog.new backend: redis, namespace: @in_queue
    end

    def output
      @output ||= Kanban::Backlog.new backend: redis, namespace: @out_queue
    end

    def work
      loop do
        id = intake.claim
        spec = intake.get id
        yield id, spec
      end
    end
  end
end
