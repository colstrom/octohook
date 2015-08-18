require 'contracts'
require 'rakuna'
require_relative 'support'
require_relative 'worker'

class Manager
  include Contracts
  include Overseer::Support::Throttle
  include Overseer::Support::Reporting
  include Rakuna::Storage::Redis

  Contract None => HashOf[String, Thread]
  def workers
    @workers ||= {}
  end

  Contract String => Thread
  def create_worker(queue)
    Thread.new do
      worker = Worker.new queue
      loop { worker.work }
    end
  end

  Contract None => ArrayOf[String]
  def unworked_queues
    redis.smembers('overseer:queues').reject { |queue| workers.has_key? queue }
  end

  Contract None => ArrayOf[Thread]
  def spawn
    unworked_queues.map { |queue| workers[queue] = create_worker queue }
  end

  Contract None => HashOf[String, Thread]
  def idle_workers
    workers.reject { |name, _| redis.sismember 'overseer:queues', name }
  end

  Contract None => ArrayOf[String]
  def reap
    idle_workers.map { |worker| worker.delete name }.map(&:kill)
  end

  Contract None => Any
  def manage
    throttle.clear if [spawn, reap].flatten.length > 0
    report 'overseer:status'
    sleep throttle.next_interval
  end
end
