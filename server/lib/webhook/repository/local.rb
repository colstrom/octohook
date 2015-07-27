require 'contracts'
require 'rugged'
require_relative '../config'

module Repository
  # Module for interacting with a local git repository
  module Local
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
  end
end
