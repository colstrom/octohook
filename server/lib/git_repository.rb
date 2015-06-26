require 'rugged'
require 'contracts'

REPOSITORY_PATH = ENV.fetch('REPOSITORY_PATH').freeze

# Module for interacting with a local git repository
module GitRepository
  include Contracts

  Contract nil => Rugged::Repository
  def repository
    Rugged::Repository.new REPOSITORY_PATH
  end

  Contract String => ArrayOf[String]
  def changed_files(commit_id)
    return [] unless repository.exists? commit_id
    commit = repository.lookup commit_id
    commit.parents.first.diff(commit).deltas.map do |delta|
      delta.new_file[:path]
    end
  end

  Contract String => ArrayOf[String]
  def changed_components(commit_id)
    relevant = changed_files(commit_id).select do |filename|
      filename.start_with? 'src'
    end
    relevant.map { |filename| filename.split('/').at(1) }.compact.uniq
  end
end
