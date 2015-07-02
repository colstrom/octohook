require 'contracts'
require 'typhoeus'
require_relative 'config'

module JenkinsSupport
  include Contracts

  JENKINS_SECRET = (ENV['JENKINS_SECRET'] || CONFIG['jenkins']['secret']).freeze

  Contract String, String => Typhoeus::Request
  def jenkins_job(component, commit_hash)
    url = "#{CONFIG['jenkins']['base_url']}/#{component}/buildWithParameters"
    Typhoeus::Request.new(url, method: 'POST', params: {
      token: JENKINS_SECRET,
      STACKATO_RELEASE_IDENTIFIER: commit_hash,
      cause: 'WebHook+Triggered'
    })
  end
end
