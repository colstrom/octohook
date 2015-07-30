require 'contracts'
require 'typhoeus'
require_relative 'repository'
require_relative '../components'
require_relative '../jenkins'

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

    # Given a pull request, returns a human-friendly description of it.
    Contract Hash => String
    def self.describe(pull_request)
      "WebHook triggered by Pull Request #{pull_request['number']}," \
      " proposing a merge of #{pull_request['head']['ref']}" \
      " into #{pull_request['base']['ref']}" \
      " at commit #{pull_request['head']['sha']}"
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

    # Given a list of changed components, queues a Jenkins job for each one.
    Contract ArrayOf[String], HashOf[Symbol, String] => Any
    def self.tell_jenkins_to_build(components, **parameters)
      components
        .map { |component| Jenkins.job component, parameters }
        .each_with_object(Typhoeus::Hydra.new) { |job, hydra| hydra.queue job }
        .run
    end
  end
end
