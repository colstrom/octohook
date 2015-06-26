require 'rugged'

REPOSITORY_PATH = ENV.fetch('REPOSITORY_PATH').freeze

module GitRepository
  def repository
    Rugged::Repository.new REPOSITORY_PATH
  end

  def changed_files(commit_id)
    return [] unless repository.exists? commit_id
    commit = repository.lookup commit_id
    commit.parents.first.diff(commit).deltas.map { |delta| delta.new_file[:path] }
  end
end
