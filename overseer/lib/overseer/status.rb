require 'contracts'
require 'rakuna'

module Overseer
  class Status < Webmachine::Resource
    include Contracts
    include Rakuna::Storage::Redis
    include Rakuna::Content::JSON

    Contract None => Hash
    def output
      {
        'overseer' => redis.hgetall('overseer:status'),
        'queues' => queue_status
      }
    end

    private

    Contract None => ArrayOf[Hash]
    def queue_status
      redis.smembers('overseer:queues').map do |name|
        redis.hgetall("overseer:queue:#{name}").merge({
          'name' => name,
          'todo' => redis.lrange("#{name}:tasks:todo", 0, -1),
          'doing' => redis.lrange("#{name}:tasks:doing", 0, -1)
        })
      end
    end
  end
end
