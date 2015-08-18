require 'contracts'
require 'octokit'

module GitHub
  include Contracts

  Contract None => Octokit::Client
  def self.client
    @client ||= Octokit::Client.new access_token: ENV['GITHUB_ACCESS_TOKEN']
  end

  def self.update_status(job, status)
    options = {
      context: job['component'],
      target_url: job['url']
    }
    client.create_status job['repository'], job['head_sha'], status, options
  end
end
