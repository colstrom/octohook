#!/usr/bin/env eye

require 'eye-http'

WORKSPACE = File.expand_path ENV.fetch('WORKSPACE', __dir__)

Eye.config do
  logger "#{WORKSPACE}/platform.log"
  http enable: true, host: '127.0.0.1', port: 9999
end

class Eye::Dsl::ApplicationOpts
  def disallow_options
    []
  end
end

Eye.application :webhook do
  daemonize true
  pid_file 'service.pid'
  start_command 'bundle exec ruby service.rb'

  group :service do
    process :overseer do
      environment 'PORT' => 9900
      working_dir "#{WORKSPACE}/overseer"
      start_command 'bundle exec rackup'
    end
  end

  group :fixture do
    process :dispatcher do
      working_dir "#{WORKSPACE}/dispatcher"
      pid_file 'fixture-service.pid'
      start_command 'bundle exec tests/fixture-service.rb'
    end
  end

  group :agent do
    process :receiver do
      environment 'PORT' => 9910
      working_dir "#{WORKSPACE}/receiver"
      start_command 'bundle exec rackup'
    end

    process :identifier do
      environment 'GITHUB_REPOSITORY' => 'ActiveState/stackato'
      working_dir "#{WORKSPACE}/identifier"
    end

    process :dispatcher do
      environment 'JENKINS_BASE_URL' => 'http://jenkins.activestate.com/view/Stackato%20components/job/component_image_jobs/job'
      working_dir "#{WORKSPACE}/dispatcher"
    end

    process :reporter do
      working_dir "#{WORKSPACE}/reporter"
    end
  end
end
