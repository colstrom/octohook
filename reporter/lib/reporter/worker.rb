require 'redis'
require 'kanban'

class Worker
  include Contracts
  include AdaptiveSupport
  include GitHubSupport
  include JenkinsSupport

  def initialize(queue, **options)
    @backend = options.fetch :backend, Redis.new
    @queue = queue
  end

  def backlog
    @backlog ||= Kanban::Backlog.new backend: @backend, namespace: queue
  end

  def work
    id = backlog.claim duration: velocity
    check_status task_id
    update_status
  end
end
