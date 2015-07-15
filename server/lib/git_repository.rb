require 'rugged'
require 'contracts'

require_relative 'config'

# Module for interacting with a local git repository
module GitRepository
  include Contracts

  Contract None => String
  def repository_path
    "#{ENV[CONFIG['repository']['env']]}/#{CONFIG['repository']['path']}"
  end

  Contract None => Rugged::Repository
  def repository
    @repository ||= Rugged::Repository.new repository_path
  end

  Contract String, String => ArrayOf[String]
  def changed_files(head_commit, base_commit)
    head = repository.lookup(head_commit)
    base = repository.lookup(base_commit)
    base.diff(head).deltas.flat_map do |delta|
      [delta.new_file[:path], delta.old_file[:path]]
    end.compact.uniq
  end

  Contract String, String => ArrayOf[String]
  def changed_components(head_commit, base_commit)
    changes = changed_files(head_commit, base_commit)
    CONFIG['components'].keys.select do |path|
      changes.any? { |filename| filename.start_with? path }
    end
  end
end
