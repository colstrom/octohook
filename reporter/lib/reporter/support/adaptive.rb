require 'contracts'
require 'descriptive_statistics'
require 'redis'

module AdaptiveSupport
  def velocity
    history.mean + (2 * history.standard_deviation)
  end

  def history
    @backend.lrange "history:#{queue}:durations", 0, -1
  end
end
