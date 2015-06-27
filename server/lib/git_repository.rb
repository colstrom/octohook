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

  Contract String, String => ArrayOf[String]
  def changed_files(head_commit, base_commit)
    head = repository.lookup(head_commit)
    base = repository.lookup(base_commit)
    base.diff(head).deltas.map { |delta| delta.new_file[:path] }
  end

  Contract String, String => ArrayOf[String]
  def changed_components(head_commit, base_commit)
    relevant = changed_files(head_commit, base_commit).select do |filename|
      filename.start_with? 'src'
    end
    relevant.map { |filename| filename.split('/').at(1) }.compact.uniq
  end
end
