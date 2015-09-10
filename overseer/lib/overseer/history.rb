require 'contracts'
require 'rakuna'

module Overseer
  class History < Webmachine::Resource
    include Contracts
    include Rakuna::Storage::Redis
    include Rakuna::Content::JSON
    include Overseer::Support::Pipeline

    Contract None => Hash
    def output
      pipeline.each_with_object({}) do |queue, h|
        h[queue] = history(queue).sort { |a, b| a['id'] <=> b['id'] }
      end
    end

    private

    Contract String => ArrayOf[Hash]
    def history(queue)
      redis.keys("#{queue}:task:*")
        .select { |key| redis.type(key) == 'hash' }
        .map do |task|
          redis.hgetall(task).merge({ 'id' => task.split(':').last.to_i })
        end
    end
  end
end
