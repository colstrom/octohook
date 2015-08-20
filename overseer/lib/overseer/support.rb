require 'contracts'
require 'exponential_backoff'
require 'redis'

module Overseer
  module Support
    module Pipeline
      include Contracts

      KNOWN_QUEUES = %w(incoming dispatching pending tracking reporting).freeze

      Contract None => Hash
      def order
        @order ||= Hash.new(-1).merge KNOWN_QUEUES.each_with_index.take(5).to_h
      end

      Contract None => ArrayOf[String]
      def pipeline
        redis.smembers('overseer:queues').sort { |a, b| order[a] <=> order[b] }
      end
    end

    module Throttle
      include Contracts

      Contract Maybe[HashOf[Symbol, Num]] => ExponentialBackoff
      def throttle(min: 0.125, max: 8)
        @throttle ||= ExponentialBackoff.new min..max
      end
    end

    module Reporting
      include Contracts

      Contract String => Any
      def report(queue)
        redis.hmset(queue, 'throttle', throttle.current_interval, 'checked_at', Time.now.utc.iso8601)
      end
    end
  end
end
