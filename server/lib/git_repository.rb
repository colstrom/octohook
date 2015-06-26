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

  def changed_components(commit_id)
    changed_files(commit_id).select {
      |filename| filename.start_with? 'src'
    }.map {
      |filename| filename.split('/').at(1)
    }.compact.uniq
  end
end
