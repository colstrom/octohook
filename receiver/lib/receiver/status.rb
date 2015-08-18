require 'kanban'
require 'rakuna'

class Status < Webmachine::Resource
  include Rakuna::Content::JSON
  include Rakuna::Storage::Redis

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
