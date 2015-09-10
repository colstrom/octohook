require 'contracts'
require 'rakuna'
require_relative 'support'

module Overseer
  class Debug < Webmachine::Resource
    include Contracts
    include Rakuna::Storage::Redis
    include Rakuna::Content::JSON
    include Overseer::Support::Pipeline

    def output
      pipeline.each_with_object({}) { |queue, h| h[queue] = tasks queue }
    end

    private

    def tasks(queue)
      redis.keys("#{queue}:task:*")
        .map { |k| k.split(':')[2].to_i }.uniq.sort
        .each_with_object({}) { |id, h| h[id] = responses(queue, id).sort.to_h }
    end

    def responses(queue, task)
      redis.keys("#{queue}:task:#{task}:response:*").each_with_object({}) do |key, hash|
        code = key.split(':').last.to_i
        hash[code] = redis.get(key).to_i
      end
    end
  end
end
