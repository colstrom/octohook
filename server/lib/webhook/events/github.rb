require 'contracts'
require 'typhoeus'
require_relative '../repository'
require_relative '../jenkins'

module Events
  # Module for handling GitHub Events.
  module GitHub
    include Contracts

    Contract Hash => Any
    def self.pull_request(payload)
      return 204 unless %w(opened synchronize).include? payload['action']
      data = payload['pull_request']
      changed_files = Repository::GitHub.changes_in_pull_request data['number']
      tell_jenkins_to_build(
        Repository::Components.changed(changed_files),
        job_parameters(payload['pull_request'])
      )
    end

    Contract Hash => String
    def self.describe(pull_request)
      "WebHook triggered by Pull Request #{pull_request['number']}, proposing a merge of #{pull_request['head']['ref']} into #{pull_request['base']['ref']} at commit #{pull_request['head']['sha']}"
    end

    Contract Hash => Hash
    def self.job_parameters(payload)
      {
        at_commit: payload['head']['sha'],
        using_branch: payload['head']['ref'],
        description: describe(payload)
      }
    end

    Contract ArrayOf[String], HashOf[Symbol, String] => Any
    def self.tell_jenkins_to_build(components, **parameters)
      components
        .map { |component| Jenkins.job component, parameters }
        .each_with_object(Typhoeus::Hydra.new) { |job, hydra| hydra.queue job }
        .run
    end
  end
end
