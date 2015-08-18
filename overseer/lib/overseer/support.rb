require 'contracts'
require 'exponential_backoff'
require 'redis'

module Overseer
  module Support
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
