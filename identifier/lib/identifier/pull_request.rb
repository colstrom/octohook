require_relative 'components'
require_relative 'github/repository'

class PullRequest
  def initialize(details)
    @number = details['number']
    @head_sha = details['head']['sha']
    @head_ref = details['head']['ref']
    @base_ref = details['base']['ref']
    @repository = details['head']['repo']['full_name']
  end

  def github
    @github ||= Octokit::Client.new auto_paginate: true, access_token: ENV['GITHUB_ACCESS_TOKEN']
  end

  def describe
    [
      "WebHook triggered by Pull Request #{@number},",
      "proposing a merge of #{@head_ref} into #{@base_ref}",
      "at commit #{@head_sha}"
    ].join ' '
  end

  def commits
    @commits ||= github.pull_request_commits @repository, @number
  end

  def changed_files
    @changed_files ||= GitHub::Repository.changes_in_pull_request @number
  end

  def changed_components
    @changed_components ||= commits.length == 250 ? Components.table.keys : Components.changed(changed_files)
  end

  def jobs
    @jobs ||= changed_components.map { |component| job(component) }
  end

  def job(component)
    {
      'component' => component,
      'job' => Components.table[component],
      'pull_request' => @number,
      'head_sha' => @head_sha,
      'head_ref' => @head_ref,
      'base_ref' => @base_ref,
      'description' => describe,
      'repository' => @repository
    }
  end
end
