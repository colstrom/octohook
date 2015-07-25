require 'contracts'
require 'rugged'
require_relative 'config'

# Module for interacting with a local git repository
module Git
  include Contracts

  Contract None => String
  def self.path
    "#{ENV[CONFIG['repository']['env']]}/#{CONFIG['repository']['path']}"
  end

  Contract None => Rugged::Repository
  def self.repository
    @repository ||= Rugged::Repository.new path
  end

  Contract String, String => ArrayOf[String]
  def self.changed_files(head_commit, base_commit)
    head = repository.lookup head_commit
    base = repository.lookup base_commit
    base.diff(head).deltas.flat_map do |delta|
      [delta.new_file[:path], delta.old_file[:path]]
    end.compact.uniq
  end

  Contract String, String => ArrayOf[String]
  def self.changed_components(head_commit, base_commit)
    changes = changed_files head_commit, base_commit
    CONFIG['components'].keys.select do |path|
      changes.any? { |filename| filename.start_with? path }
    end
  end

  Contract String, String => ArrayOf[String]
  def self.changes_for_humans(head_commit, base_commit)
    changed_components(head_commit, base_commit).map do |name|
      name.sub(%r{^src/(services/)?}, '').sub(/_ng$/, '').sub('_', ' ')
    end
  end
end
