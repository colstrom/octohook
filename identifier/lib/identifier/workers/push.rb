require 'contracts'
require 'multi_json'
require 'kanban'
require 'redis'
require_relative '../components'
require_relative '../push'

class PushWorker
  include Contracts

  Contract None => Redis
  def redis
    @redis ||= Redis.new
  end

  Contract None => Kanban::Backlog
  def incoming
    @incoming ||= Kanban::Backlog.new backend: redis, namespace: 'incoming-push'
  end

  Contract None => Kanban::Backlog
  def dispatch
    @dispatch ||= Kanban::Backlog.new backend: redis, namespace: 'dispatching'
  end

  Contract PushEvent, RespondTo[:to_i] => Any
  def work(event, id)
    event.jobs.each { |job| dispatch.add job }
    incoming.complete id
  end

  Contract None => Any
  def consider_working
    id = incoming.claim
    event = PushEvent.new MultiJson.load incoming.get(id)['raw']
    event.important? ? work(event, id) : incoming.unworkable(id)
  end
end
