require 'contracts'
require 'typhoeus'
require_relative 'config'

# Module for interacting with a Jenkins server.
module Jenkins
  include Contracts

  # Returns a request object for a Jenkins job.
  Contract String, HashOf[Symbol, String] => Typhoeus::Request
  def self.job(component, at_commit:, using_branch:, description:)
    job_name = CONFIG['components'][component]
    url = "#{CONFIG['jenkins']['base_url']}/#{job_name}/buildWithParameters"
    params = {
      token: ENV['JENKINS_SECRET'],
      STACKATO_RELEASE_IDENTIFIER: at_commit,
      USING_BRANCH: using_branch,
      DESCRIPTION: description,
      cause: 'WebHook'
    }
    Typhoeus::Request.new(url, method: 'POST', params: params)
  end
end
