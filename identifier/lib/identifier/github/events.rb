require 'contracts'
require_relative 'repository'
require_relative '../components'

module GitHub
  # Module for handling GitHub Events.
  module Events
    include Contracts

    # Handles a pull request event.
    Contract Hash => Any
    def self.pull_request(payload)
      return 204 unless %w(opened synchronize).include? payload['action']
      data = payload['pull_request']
      changed_files = GitHub::Repository.changes_in_pull_request data['number']
      tell_jenkins_to_build(
        Components.changed(changed_files),
        job_parameters(data)
      )
    end

    # Given a payload, returns parameters for a Jenkins job.
    Contract Hash => Hash
    def self.job_parameters(payload)
      {
        at_commit: payload['head']['sha'],
        using_branch: payload['head']['ref'],
        description: describe(payload)
      }
    end
  end
end
