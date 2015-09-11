require 'kanban'
require 'rakuna'

class Status < Rakuna::Resource::Basic
  include Rakuna::Provides::JSON
  include Rakuna::Data::Redis

  def output
    {
      'status' => 'online',
      'backlog' => backlog_status,
      'storage' => storage_status
    }
  end

  private

  def backlog_status
    {
      'todo' => backlog.todo.size,
      'doing' => backlog.doing.size
    }
  end

  def storage_status
    { 'connected' => redis.connected? }
  end

  def backlog
    @backlog ||= Kanban::Backlog.new backend: redis, namespace: 'incoming'
  end
end
