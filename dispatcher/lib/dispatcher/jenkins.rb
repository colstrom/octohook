require 'contracts'
require 'typhoeus'

require_relative 'jenkins/job'

# Module for interacting with a Jenkins server.
module Jenkins
  include Contracts

  # Returns a request object for a Jenkins job.
  Contract Jenkins::Job => Typhoeus::Request
  def self.dispatch(job)
    Typhoeus::Request.new job.url, method: 'POST', params: job.parameters
  end

  Contract String => Typhoeus::Request
  def self.poll(url)
    Typhoeus::Request.new "#{url}api/json", method: 'GET', params: { token: ENV['JENKINS_SECRET'] }
  end
end
