require_relative 'service'

Webmachine.application.configure do |config|
  config.ip = '0.0.0.0'
  config.port = ENV['PORT'] if ENV['PORT']
  config.adapter = :Reel
end

Webmachine.application.run
