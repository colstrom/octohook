require 'contracts'
require 'kanban'
require 'rakuna'
require_relative 'support'

class Worker
  include Contracts
  include Overseer::Support::Throttle
  include Overseer::Support::Reporting
  include Rakuna::Storage::Redis

  Contract String => Any
  def initialize(queue)
    @queue = queue
  end

  Contract None => Kanban::Backlog
  def backlog
    @backlog ||= Kanban::Backlog.new backend: redis, namespace: @queue
  end

  Contract None => Any
  def work
    throttle.clear unless backlog.groom.empty?
    report "overseer:queue:#{@queue}"
    sleep throttle.next_interval
  end
end
