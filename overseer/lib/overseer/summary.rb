require 'contracts'
require 'rakuna'
require_relative 'support'

module Overseer
  class Summary < Webmachine::Resource
    include Contracts
    include Rakuna::Storage::Redis
    include Rakuna::Content::JSON
    include Overseer::Support::Pipeline

    Contract None => Hash
    def output
      {
        'overseer' => redis.hgetall('overseer:status'),
        'pipeline' => summary
      }
    end

    private

    Contract None => Hash
    def summary
      pipeline.each_with_object({}) { |queue, h| h[queue] = summarize queue }
    end

    Contract String => Hash
    def summarize(queue)
      redis.hgetall("overseer:queue:#{queue}").merge({
        'todo' => redis.lrange("#{queue}:tasks:todo", 0, -1),
        'doing' => redis.lrange("#{queue}:tasks:doing", 0, -1)
      })
    end
  end
end
