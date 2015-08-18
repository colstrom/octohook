require 'kanban'
require 'rakuna'
require_relative 'github/payload'

class Webhook < Rakuna::Resource::Action
  include GitHub::Payload
  include Rakuna::Content::JSON
  include Rakuna::Content::Validation
  include Rakuna::Storage::Redis

  def valid?
    valid_signature?
  end

  def input
    backlog.add task
  end

  private

  def task
    @task ||= { 'raw' => request.body.to_s }
  end

  def backlog
    @backlog ||= Kanban::Backlog.new backend: redis, namespace: 'incoming'
  end
end
