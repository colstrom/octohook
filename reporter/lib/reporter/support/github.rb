require 'contracts'
require 'octokit'

module GitHubSupport
  include Contracts

  Contract None => Octokit::Client
  def github
    @github ||= do
      options = {
        access_token: ENV['GITHUB_ACCESS_TOKEN'],
        auto_paginate: true
      }
      Octokit::Client.new options
    end
  end
end
