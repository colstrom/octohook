require 'contracts'
require 'octokit'
require_relative 'components'

module Repository
  # module for dealing with remote repository.
  module GitHub
    include Contracts

    REPOSITORY = CONFIG['github']['repository'].freeze

    # Returns an authenticated GitHub client.
    Contract None => Octokit::Client
    def self.client
      @client ||= Octokit::Client.new access_token: ENV['GITHUB_ACCESS_TOKEN'], auto_paginate: true
    end

    # Returns the default branch name.
    Contract None => String
    def self.default_branch
      client.repository(REPOSITORY)[:default_branch] || 'master'
    end

    # Given a branch, returns the ID of the latest commit for that branch.
    Contract Maybe[({branch: String})] => String
    def self.head(branch: default_branch)
      client.branch(REPOSITORY, branch)[:commit][:sha]
    end

    # Given a commit, returns the parent of that commit.
    Contract String => String
    def self.parent(commit_id)
      client.commit(REPOSITORY, commit_id)[:parents].first[:sha]
    end

    # Given a pull request ID, returns a list of files changed in it.
    Contract RespondTo[:to_i] => ArrayOf[String]
    def self.changes_in_pull_request(pull_request_id)
      client.pull_request_files(REPOSITORY, pull_request_id).map do |file|
        file[:filename]
      end
    end

    # Given two commits, returns a list of changed files between them.
    def self.changed_files(head_commit, base_commit)
      client.compare(REPOSITORY, base_commit, head_commit)[:files].map do |file|
        file[:filename]
      end
    end
  end
end
