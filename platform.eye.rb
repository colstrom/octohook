#!/usr/bin/env eye

WORKSPACE = File.expand_path ENV.fetch('WORKSPACE', __dir__)

Eye.config do
  logger "#{WORKSPACE}/platform.log"
end

class Eye::Dsl::ApplicationOpts
  def disallow_options
    []
  end
end

Eye.application :webhook do
  daemonize true
  pid_file 'service.pid'
  start_command 'bundle exec rackup'

  group :service do
    process :overseer do
      environment 'PORT' => 9900
      working_dir "#{WORKSPACE}/overseer"
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
    end

    process :identifier do
      environment 'PORT' => 9911
      environment 'REPOSITORY' => 'ActiveState/stackato'
      start_command 'bundle exec ruby service.rb'
      working_dir "#{WORKSPACE}/identifier"
    end

    process :dispatcher do
      environment 'PORT' => 9912
      environment 'JENKINS_BASE_URL' => 'http://jenkins.activestate.com/view/Stackato%20components/job/component_image_jobs/job'
      start_command 'bundle exec ruby service.rb'
      working_dir "#{WORKSPACE}/dispatcher"
    end

    process :reporter do
      environment 'PORT' => 9914
      start_command 'bundle exec ruby service.rb'
      working_dir "#{WORKSPACE}/reporter"
    end
  end
end
