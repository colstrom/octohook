require 'contracts'
require 'multi_json'
require 'kanban'
require 'redis'
require_relative 'components'
require_relative 'pull_request'

class Worker
  include Contracts

  Contract None => Redis
  def redis
    @redis ||= Redis.new
  end

  Contract None => Kanban::Backlog
  def pull_requests
    @pull_requests ||= Kanban::Backlog.new backend: redis, namespace: 'incoming'
  end

  Contract None => Kanban::Backlog
  def dispatch
    @dispatch ||= Kanban::Backlog.new backend: redis, namespace: 'dispatching'
  end

  Contract RespondTo[:to_i] => Hash
  def task_details(id)
    task = pull_requests.get id
    MultiJson.load task['raw']
  end

  Contract RespondTo[:to_i], Hash => Any
  def work(id, details)
    PullRequest.new(details['pull_request']).jobs.each { |job| dispatch.add job }
    pull_requests.complete id
  end

  Contract None => Any
  def consider_working
    id = pull_requests.claim
    details = task_details id
    %w(opened synchronize).include?(details['action']) ? work(id, details) : pull_requests.unworkable(id)
  end
end
