require 'kanban'
require 'rakuna'

class Webhook < Rakuna::Resource::Action
  include Rakuna::Content::JSON
  include Rakuna::Validation::Signature
  include Rakuna::Data::Redis

  def malformed_request?
    true unless signature_valid?
  end

  def signature_secret
    ENV['GITHUB_SECRET']
  end

  def content_signature
    request.headers['X-Hub-Signature']
  end

  def execute
    true if backlog.add task
  end

  def event
    request.headers['X-Github-Event']
  end

  private

  def task
    @task ||= { 'raw' => request.body.to_s }
  end

  def backlog
    @backlog ||= Kanban::Backlog.new backend: redis, namespace: "incoming-#{event}"
  end
end
