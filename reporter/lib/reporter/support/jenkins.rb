require 'contracts'
require 'jenkins_api_client'

module JenkinsSupport
  include Contracts

  Contract None => JenkinsAPI::Client
  def jenkins
    @jenkins ||= JenkinsAPI::Client.new
  end
end
